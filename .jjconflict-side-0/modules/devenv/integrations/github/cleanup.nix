{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.github.workflows.cleanup;

  yamlFormat = pkgs.formats.yaml { };

  ghstackCondition = "startsWith(github.head_ref, 'gh/') && endsWith(github.head_ref, '/head')";
in
{
  options.github.workflows.cleanup = {
    enable = lib.mkEnableOption "cleanup workflow";

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
    };
  };

  config = lib.mkIf (config.github.enable && cfg.enable) {
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
              token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
            }
            // cfg.settings.checkout;
          }
          {
            env = {
              BASE_REF = "\${{ github.base_ref }}";
              HEAD_REF = "\${{ github.head_ref }}";
              REPO = "\${{ github.repository }}";
            };
            "if" = "!(${ghstackCondition})";
            run = "git push origin --delete \"$HEAD_REF\" || true";
          }
          {
            env = {
              BASE_REF = "\${{ github.base_ref }}";
              HEAD_REF = "\${{ github.head_ref }}";
              REPO = "\${{ github.repository }}";
            };
            "if" = ghstackCondition;
            run = "for role in base head orig; do git push origin --delete \"\${HEAD_REF%/head}/$role\" || true; done";
          }
        ];
      };
      name = "Cleanup";
      on.pull_request.types = [ "closed" ];
      permissions.contents = "write";
    };
  };
}
