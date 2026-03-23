{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.github.workflows.integration;

  yamlFormat = pkgs.formats.yaml { };
in
{
  options.github.workflows.integration = {
    enable = mkEnableOption "integration workflow";

    settings = {
      cachix-push = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = {
          authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
          name = "shikanime-studio";
        };
        description = "Overrides for cachix-push";
      };
      checkout = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = {
          fetch-depth = 0;
          token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
        };
        description = "Overrides for checkout";
      };
      create-github-app-token = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = {
          app-id = "\${{ vars.OPERATOR_APP_ID }}";
          private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
          permission-contents = "read";
        };
        description = "Overrides for create-github-app-token";
      };
      direnv = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for direnv";
      };
      nix-flake-check = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for nix-flake-check";
      };
      setup-nix = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default.github_access_token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
        description = "Overrides for setup-nix";
      };
    };
  };

  config = mkIf cfg.enable {
    github.settings.workflows.integration = {
      name = "Integration";
      on.pull_request.branches = [
        "main"
        "gh/*/*/base"
      ];
      permissions.contents = "read";
    };
  };
}
