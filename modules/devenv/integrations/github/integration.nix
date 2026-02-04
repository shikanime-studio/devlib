{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.github.workflows.integration;

  yamlFormat = pkgs.formats.yaml { };
in
{
  options.github.workflows.integration = {
    enable = lib.mkEnableOption "integration workflow";

    settings = {
      cachix-push = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = {
          authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
          name = "shikanime-studio";
        };
        description = "Overrides for cachix-push";
      };
      checkout = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = {
          fetch-depth = 0;
          token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
        };
        description = "Overrides for checkout";
      };
      create-github-app-token = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = {
          app-id = "\${{ vars.OPERATOR_APP_ID }}";
          private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
          permission-contents = "read";
        };
        description = "Overrides for create-github-app-token";
      };
      direnv = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for direnv";
      };
      nix-flake-check = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for nix-flake-check";
      };
      setup-nix = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default.github_access_token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
        description = "Overrides for setup-nix";
      };
    };
  };

  config = lib.mkIf (config.github.enable && cfg.enable) {
    github.settings.workflows.integration = {
      jobs.check = {
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
            env = cfg.settings.direnv;
            run = "nix run nixpkgs#direnv allow";
          }
          {
            env = cfg.settings.direnv;
            run = "nix run nixpkgs#direnv export gha >> \"$GITHUB_ENV\"";
          }
          {
            env = cfg.settings.nix-flake-check;
            run = "nix flake check --accept-flake-config --no-pure-eval";
          }
        ];
      };
      name = "Integration";
      on.pull_request.branches = [
        "main"
        "gh/*/*/base"
      ];
      permissions.contents = "read";
    };
  };
}
