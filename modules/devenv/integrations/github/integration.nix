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
          continue-on-error = true;
          uses = "cachix/cachix-action@v16";
          "with" = {
            authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
            name = "shikanime-studio";
          };
        };
        description = "Overrides for cachix-push";
      };
      checkout = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = {
          uses = "actions/checkout@v6";
          "with" = {
            fetch-depth = 0;
            token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
          };
        };
        description = "Overrides for checkout";
      };
      create-github-app-token = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = {
          continue-on-error = true;
          id = "createGithubAppToken";
          uses = "actions/create-github-app-token@v2";
          "with" = {
            app-id = "\${{ vars.OPERATOR_APP_ID }}";
            private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
            permission-contents = "read";
          };
        };
        description = "Overrides for create-github-app-token";
      };
      direnv-allow = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default.run = "nix run nixpkgs#direnv allow";
        description = "Overrides for direnv-allow";
      };
      direnv-export = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default.run = "nix run nixpkgs#direnv export gha >> \"$GITHUB_ENV\"";
        description = "Overrides for direnv-export";
      };
      nix-flake-check = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default.run = "nix flake check --accept-flake-config --no-pure-eval";
        description = "Overrides for nix-flake-check";
      };
      setup-nix = lib.mkOption {
        type = lib.types.submodule { freeformType = yamlFormat.type; };
        default = {
          uses = "cachix/install-nix-action@v31";
          "with" = {
            github_access_token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
          };
        };
        description = "Overrides for setup-nix";
      };
    };
  };

  config = lib.mkIf (config.github.enable && cfg.enable) {
    github.settings.workflows.integration = {
      jobs.check = {
        runs-on = "ubuntu-latest";
        steps = [
          cfg.settings.create-github-app-token
          cfg.settings.checkout
          cfg.settings.setup-nix
          cfg.settings.cachix-push
          cfg.settings.direnv-allow
          cfg.settings.direnv-export
          cfg.settings.nix-flake-check
        ];
      };
      name = "Integration";
      on = {
        pull_request.branches = [
          "main"
          "gh/*/*/base"
        ];
        workflow_call = { };
      };
      permissions.contents = "read";
    };
  };
}
