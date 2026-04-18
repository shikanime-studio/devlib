{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.github.workflows.cleanup;

  yamlFormat = pkgs.formats.yaml { };
in
{
  options.github.workflows.cleanup = {
    enable = mkEnableOption "cleanup workflow";

    settings = {
      create-github-app-token = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for create-github-app-token";
      };
      cleanup = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for cleanup";
      };
      setup-nix = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for setup-nix";
      };
    };
  };

  config = mkIf cfg.enable {
    github.settings.workflows.cleanup = {
      jobs.cleanup = {
        "if" = "\${{ github.event.pull_request.head.repo.fork == false }}";
        runs-on = "ubuntu-slim";
        steps = [
          {
            id = "createGithubAppToken";
            uses = "actions/create-github-app-token@v3";
            "with" = {
              app-id = "\${{ vars.OPERATOR_APP_ID }}";
              private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
              permission-contents = "write";
            }
            // cfg.settings.create-github-app-token;
          }
          {
            uses = "shikanime-studio/actions/nix/setup@v9";
            "with" = {
              github-token = "\${{ steps.createGithubAppToken.outputs.token }}";
            }
            // cfg.settings.setup-nix;
          }
          {
            uses = "shikanime-studio/actions/cleanup@v9";
            "with" = {
              github-token = "\${{ steps.createGithubAppToken.outputs.token }}";
              pull-request-url = "\${{ github.event.pull_request.html_url }}";
            }
            // cfg.settings.cleanup;
          }
        ];
      };
      name = "Cleanup";
      on.pull_request.types = [ "closed" ];
      permissions.contents = "read";
    };
  };
}
