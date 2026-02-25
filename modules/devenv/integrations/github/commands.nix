{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.github.workflows.commands;

  yamlFormat = pkgs.formats.yaml { };

  githubToken = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
in
{
  options.github.workflows.commands = {
    enable = lib.mkEnableOption "commands workflow";

    settings = {
      backport = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for backport";
      };
      checkout = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for checkout";
      };
      close = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for close";
      };
      create-github-app-token = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for create-github-app-token";
      };
      land = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for land";
      };
      rebase = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for rebase";
      };
      setup-nix = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for setup-nix";
      };
    };
  };

  config = lib.mkIf (config.github.enable && cfg.enable) {
    github.settings.workflows.commands = {
      jobs = {
        backport = {
          "if" =
            "github.event.issue.pull_request != null && contains(github.event.comment.body, '.backport')";
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
                permission-issues = "write";
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
              uses = "shikanime-studio/actions/backport@v7";
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
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v2";
              "with" = {
                app-id = "\${{ vars.OPERATOR_APP_ID }}";
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                permission-contents = "write";
                permission-issues = "write";
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
              uses = "shikanime-studio/actions/close@v7";
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
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v2";
              "with" = {
                app-id = "\${{ vars.OPERATOR_APP_ID }}";
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                permission-contents = "write";
                permission-issues = "write";
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
              uses = "shikanime-studio/actions/land@v7";
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
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v2";
              "with" = {
                app-id = "\${{ vars.OPERATOR_APP_ID }}";
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                permission-contents = "write";
                permission-issues = "write";
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
              uses = "shikanime-studio/actions/rebase@v7";
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
      };
      name = "Commands";
      on.issue_comment.types = [ "created" ];
      permissions = {
        contents = "write";
        issues = "write";
        pull-requests = "write";
      };
    };
  };
}
