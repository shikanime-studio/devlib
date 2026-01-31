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
      checkout = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for checkout";
      };
      create-github-app-token = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for create-github-app-token";
      };
      setup-nix = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = { };
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
            run = "nix run nixpkgs#direnv allow";
          }
          {
            run = "nix run nixpkgs#direnv export gha >> \"$GITHUB_ENV\"";
          }
          {
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
