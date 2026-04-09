{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.github.workflows.update;

  yamlFormat = pkgs.formats.yaml { };

  githubToken = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
in
{
  options.github.workflows.update = {
    enable = mkEnableOption "update";

    settings = {
      checkout = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for checkout 'with' section";
      };
      create-github-app-token = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for create-github-app-token 'with' section";
      };
      setup-nix = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for setup-nix 'with' section";
      };
      stale = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for stale 'with' section";
      };
      update = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for update 'with' section";
      };
    };
  };

  config = mkIf config.github.workflows.update.enable {
    github.settings.workflows.update = {
      jobs = {
        dependencies = {
          runs-on = "ubuntu-slim";
          permissions = {
            contents = "write";
            pull-requests = "write";
          };
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v3";
              "with" = {
                app-id = "\${{ vars.OPERATOR_APP_ID }}";
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                permission-contents = "write";
                permission-pull-requests = "write";
              }
              // cfg.settings.create-github-app-token;
            }
            {
              uses = "shikanime-studio/actions/checkout@v9";
              "with" = {
                github-token = githubToken;
                gpg-passphrase = "\${{ secrets.GPG_PASSPHRASE }}";
                gpg-private-key = "\${{ secrets.GPG_PRIVATE_KEY }}";
                sign-commits = true;
                username = "operator6o";
              }
              // cfg.settings.checkout;
            }
            {
              uses = "shikanime-studio/actions/nix/setup@v9";
              "with" = {
                github-token = githubToken;
              }
              // cfg.settings.setup-nix;
            }
            {
              uses = "shikanime-studio/actions/update@v9";
              "with" = {
                github-token = githubToken;
                username = "operator6o";
              }
              // cfg.settings.update;
            }
          ];
        };
        stale = {
          runs-on = "ubuntu-slim";
          permissions = {
            issues = "write";
            pull-requests = "write";
          };
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v3";
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
      permissions.contents = "read";
    };
  };
}
