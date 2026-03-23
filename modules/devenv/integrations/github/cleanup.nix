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

  githubToken = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
in
{
  options.github.workflows.cleanup = {
    enable = mkEnableOption "cleanup workflow";

    settings = {
      checkout = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for checkout";
      };
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
    };
  };

  config = mkIf cfg.enable {
    github.settings.workflows.cleanup = {
      jobs.cleanup = {
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
            }
            // cfg.settings.create-github-app-token;
          }
          {
            uses = "actions/checkout@v6";
            "with" = {
              fetch-depth = 0;
              ref = "main";
              token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
            }
            // cfg.settings.checkout;
          }
          {
            uses = "shikanime-studio/actions/cleanup@v7";
            "with" = {
              github-token = githubToken;
              pull-request-url = "\${{ github.event.pull_request.html_url }}";
            }
            // cfg.settings.cleanup;
          }
        ];
      };
      name = "Cleanup";
      on.pull_request.types = [ "closed" ];
      permissions.contents = "write";
    };
  };
}
