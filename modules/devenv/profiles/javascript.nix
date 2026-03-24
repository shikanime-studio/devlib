{ lib, pkgs, ... }:

with lib;

{
  imports = [ ./base.nix ];

  gitignore.templates = [ "tt:node" ];

  renovate.settings.npm.enabled = true;

  languages.javascript = {
    enable = true;
    corepack.enable = true;
    package = pkgs.nodejs;
    pnpm = {
      enable = true;
      install.enable = true;
    };
  };

  treefmt.config.settings.global.excludes = [ "node_modules/*" ];

  github.settings.workflows = {
    javascript = {
      name = "JavaScript";
      on.workflow_call = {
        inputs = {
          "node-version" = {
            type = "string";
            default = "lts/*";
          };
        };
        secrets = {
          OPERATOR_PRIVATE_KEY.required = true;
        };
      };

      permissions.contents = "read";

      jobs = {
        build = {
          name = "Build";
          needs = [ "check" ];
          runs-on = "ubuntu-latest";
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v3";
              "with" = {
                app-id = "\${{ vars.OPERATOR_APP_ID }}";
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                permission-contents = "read";
              };
            }
            {
              uses = "actions/checkout@v6";
              "with" = {
                fetch-depth = 0;
                token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
              };
            }
            {
              uses = "cachix/install-nix-action@v31";
              "with".github_access_token =
                "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
            }
            { run = "nix run nixpkgs#direnv allow"; }
            { run = "nix run nixpkgs#direnv export gha >> \"$GITHUB_ENV\""; }
            { run = "corepack pnpm install --frozen-lockfile"; }
            { run = "corepack pnpm --recursive build"; }
          ];
        };

        check = {
          name = "Check";
          runs-on = "ubuntu-latest";
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v3";
              "with" = {
                app-id = "\${{ vars.OPERATOR_APP_ID }}";
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                permission-contents = "read";
              };
            }
            {
              uses = "actions/checkout@v6";
              "with" = {
                fetch-depth = 0;
                token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
              };
            }
            {
              uses = "cachix/install-nix-action@v31";
              "with".github_access_token =
                "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
            }
            { run = "nix run nixpkgs#direnv allow"; }
            { run = "nix run nixpkgs#direnv export gha >> \"$GITHUB_ENV\""; }
            { run = "corepack pnpm install --frozen-lockfile"; }
            { run = "corepack pnpm --recursive check"; }
          ];
        };

        lint = {
          name = "Lint";
          needs = [ "check" ];
          runs-on = "ubuntu-latest";
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v3";
              "with" = {
                app-id = "\${{ vars.OPERATOR_APP_ID }}";
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                permission-contents = "read";
              };
            }
            {
              uses = "actions/checkout@v6";
              "with" = {
                fetch-depth = 0;
                token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
              };
            }
            {
              uses = "cachix/install-nix-action@v31";
              "with".github_access_token =
                "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
            }
            { run = "nix run nixpkgs#direnv allow"; }
            { run = "nix run nixpkgs#direnv export gha >> \"$GITHUB_ENV\""; }
            { run = "corepack pnpm install --frozen-lockfile"; }
            { run = "corepack pnpm --recursive lint"; }
          ];
        };
      };
    };

    integration.jobs.javascript = {
      uses = "./.github/workflows/javascript.yaml";
      secrets.OPERATOR_PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
    };

    release.jobs = {
      javascript = {
        uses = "./.github/workflows/javascript.yaml";
        secrets.OPERATOR_PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
      };

      release-branch.needs = [ "javascript" ];
      release-tag.needs = [ "javascript" ];
    };
  };
}
