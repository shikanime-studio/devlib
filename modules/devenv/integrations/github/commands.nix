{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.github.workflows.commands;

  yamlFormat = pkgs.formats.yaml { };

  githubToken = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
in
{
  options.github.workflows.commands = {
    enable = mkEnableOption "commands workflow";

    settings = {
      backport = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for backport";
      };
      close = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for close";
      };
      create-github-app-token = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for create-github-app-token";
      };
      land = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for land";
      };
      rebase = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for rebase";
      };
      run = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for run";
      };
      setup-nix = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for setup-nix";
      };
    };
  };

  config = mkIf cfg.enable {
    github.settings.workflows.commands = {
      jobs = {
        backport = {
          "if" =
            "github.event.issue.pull_request != null && contains(github.event.comment.body, '.backport')";
          runs-on = "ubuntu-slim";
          permissions = {
            contents = "write";
            issues = "write";
            pull-requests = "write";
          };
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v3.1.1";
              "with" = {
                client-id = "\${{ vars.OPERATOR_APP_CLIENT_ID }}";
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                permission-contents = "write";
                permission-issues = "write";
                permission-pull-requests = "write";
                permission-workflows = "write";
              }
              // cfg.settings.create-github-app-token;
            }
            {
              uses = "shikanime-studio/actions/nix/setup@v9";
              "with" = {
                github-token = githubToken;
              }
              // cfg.settings.setup-nix;
            }
            {
              uses = "shikanime-studio/actions/command/backport@v9";
              "with" = {
                github-token = githubToken;
                gpg-passphrase = "\${{ secrets.GPG_PASSPHRASE }}";
                gpg-private-key = "\${{ secrets.GPG_PRIVATE_KEY }}";
                sign-commits = true;
              }
              // cfg.settings.backport;
            }
          ];
        };
        close = {
          "if" = "github.event.issue.pull_request != null && contains(github.event.comment.body, '.close')";
          runs-on = "ubuntu-slim";
          permissions = {
            contents = "write";
            issues = "write";
            pull-requests = "write";
          };
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v3.1.1";
              "with" = {
                client-id = "\${{ vars.OPERATOR_APP_CLIENT_ID }}";
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                permission-contents = "write";
                permission-issues = "write";
                permission-pull-requests = "write";
              }
              // cfg.settings.create-github-app-token;
            }
            {
              uses = "shikanime-studio/actions/nix/setup@v9";
              "with" = {
                github-token = githubToken;
              }
              // cfg.settings.setup-nix;
            }
            {
              uses = "shikanime-studio/actions/command/close@v9";
              "with" = {
                github-token = githubToken;
                username = "operator6o";
              }
              // cfg.settings.close;
            }
          ];
        };
        land = {
          "if" = "github.event.issue.pull_request != null && contains(github.event.comment.body, '.land')";
          runs-on = "ubuntu-slim";
          permissions = {
            contents = "write";
            issues = "write";
            pull-requests = "write";
          };
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v3.1.1";
              "with" = {
                client-id = "\${{ vars.OPERATOR_APP_CLIENT_ID }}";
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                permission-administration = "read";
                permission-contents = "write";
                permission-issues = "write";
                permission-pull-requests = "write";
              }
              // cfg.settings.create-github-app-token;
            }
            {
              uses = "shikanime-studio/actions/nix/setup@v9";
              "with" = {
                github-token = githubToken;
              }
              // cfg.settings.setup-nix;
            }
            {
              uses = "shikanime-studio/actions/command/land@v9";
              "with" = {
                github-token = githubToken;
                email = "operator6o@shikanime.studio";
                fullname = "Operator 6O";
                username = "operator6o";
                gpg-passphrase = "\${{ secrets.GPG_PASSPHRASE }}";
                gpg-private-key = "\${{ secrets.GPG_PRIVATE_KEY }}";
                sign-commits = true;
              }
              // cfg.settings.land;
            }
          ];
        };
        rebase = {
          "if" = "github.event.issue.pull_request != null && contains(github.event.comment.body, '.rebase')";
          runs-on = "ubuntu-slim";
          permissions = {
            contents = "write";
            issues = "write";
            pull-requests = "write";
          };
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v3.1.1";
              "with" = {
                client-id = "\${{ vars.OPERATOR_APP_CLIENT_ID }}";
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                permission-contents = "write";
                permission-issues = "write";
                permission-pull-requests = "write";
              }
              // cfg.settings.create-github-app-token;
            }
            {
              uses = "shikanime-studio/actions/nix/setup@v9";
              "with" = {
                github-token = githubToken;
              }
              // cfg.settings.setup-nix;
            }
            {
              uses = "shikanime-studio/actions/command/rebase@v9";
              "with" = {
                github-token = githubToken;
                email = "operator6o@shikanime.studio";
                fullname = "Operator 6O";
                username = "operator6o";
                gpg-passphrase = "\${{ secrets.GPG_PASSPHRASE }}";
                gpg-private-key = "\${{ secrets.GPG_PRIVATE_KEY }}";
                sign-commits = true;
              }
              // cfg.settings.rebase;
            }
          ];
        };
        run = {
          "if" = "github.event.issue.pull_request != null && contains(github.event.comment.body, '.run')";
          runs-on = "ubuntu-slim";
          permissions = {
            contents = "write";
            issues = "write";
            pull-requests = "write";
          };
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v3.1.1";
              "with" = {
                client-id = "\${{ vars.OPERATOR_APP_CLIENT_ID }}";
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                permission-contents = "write";
                permission-issues = "write";
                permission-pull-requests = "write";
              }
              // cfg.settings.create-github-app-token;
            }
            {
              uses = "shikanime-studio/actions/nix/setup@v9";
              "with" = {
                github-token = githubToken;
              }
              // cfg.settings.setup-nix;
            }
            {
              uses = "shikanime-studio/actions/command/run@v9";
              "with" = {
                github-token = githubToken;
                username = "operator6o";
              }
              // cfg.settings.run;
            }
          ];
        };
      };
      name = "Commands";
      on.issue_comment.types = [ "created" ];
      permissions.contents = "read";
    };
  };
}
