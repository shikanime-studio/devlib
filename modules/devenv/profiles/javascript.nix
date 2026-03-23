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

  github.settings.workflows.javascript = {
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
      check = {
        runs-on = "ubuntu-latest";
        steps = [
          {
            continue-on-error = true;
            id = "createGithubAppToken";
            uses = "actions/create-github-app-token@v2";
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
          { run = "pnpm install --frozen-lockfile"; }
          { run = "pnpm run check"; }
        ];
      };

      build = {
        needs = [ "check" ];
        runs-on = "ubuntu-latest";
        steps = [
          {
            continue-on-error = true;
            id = "createGithubAppToken";
            uses = "actions/create-github-app-token@v2";
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
            uses = "actions/setup-node@v4";
            "with" = {
              node-version = "\${{ inputs['node-version'] }}";
              cache = "pnpm";
            };
          }
          {
            uses = "pnpm/action-setup@v4";
            "with" = {
              version = "latest";
            };
          }
          { run = "pnpm install --frozen-lockfile"; }
          { run = "pnpm run build"; }
        ];
      };
    };
  };
}
