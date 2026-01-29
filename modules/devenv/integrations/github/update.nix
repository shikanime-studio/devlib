{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.github.workflows.update;

  yamlFormat = pkgs.formats.yaml { };

  githubToken = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
in
{
  options.github.workflows.update = {
    enable = lib.mkEnableOption "update";

    settings = {
      checkout = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for checkout 'with' section";
      };
      create-github-app-token = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for create-github-app-token 'with' section";
      };
      setup-nix = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for setup-nix 'with' section";
      };
      stale = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for stale 'with' section";
      };
      update = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for update 'with' section";
      };
    };
  };

  config = lib.mkIf config.github.workflows.update.enable {
    github.settings.workflows.update = {
      jobs = {
        dependencies = {
          runs-on = "ubuntu-slim";
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v2";
              "with" = {
                app-id = "\${{ vars.OPERATOR_APP_ID }}";
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                permission-contents = "write";
                permission-pull-requests = "write";
              }
              // cfg.settings.create-github-app-token;
            }
            {
              uses = "actions/checkout@v6";
              "with" = {
                fetch-depth = 0;
                token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
              }
              // cfg.settings.checkout;
            }
            {
              uses = "cachix/install-nix-action@v31";
              "with" = {
                github_access_token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
              }
              // cfg.settings.setup-nix;
            }
            {
              uses = "shikanime-studio/actions/update@v7";
              "with" = {
                email = "operator6o@shikanime.studio";
                fullname = "Operator 6O";
                github-token = githubToken;
                gpg-passphrase = "\${{ secrets.GPG_PASSPHRASE }}";
                gpg-private-key = "\${{ secrets.GPG_PRIVATE_KEY }}";
                sign-commits = true;
                username = "operator6o";
              }
              // cfg.settings.update;
            }
          ];
        };
        stale = {
          runs-on = "ubuntu-slim";
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v2";
              "with" = {
                app-id = "\${{ vars.OPERATOR_APP_ID }}";
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                permission-issues = "write";
                permission-pull-requests = "write";
              }
              // cfg.settings.create-github-app-token;
            }
            {
              uses = "actions/stale@v10";
              "with" = {
                days-before-close = 14;
                days-before-stale = 30;
                repo-token = githubToken;
                stale-issue-label = "stale";
                stale-pr-label = "stale";
              }
              // cfg.settings.stale;
            }
          ];
        };
      };
      name = "Update";
      on = {
        schedule = [
          { cron = "0 4 * * 0"; }
        ];
        workflow_dispatch = { };
      };
      permissions = {
        contents = "write";
        issues = "write";
        pull-requests = "write";
      };
    };
  };
}
