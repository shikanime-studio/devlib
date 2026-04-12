{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.github.workflows.triage;

  yamlFormat = pkgs.formats.yaml { };

  githubToken = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";

  ghstackCondition = "startsWith(github.head_ref, 'gh/') && endsWith(github.head_ref, '/head')";

  mergeCondition =
    "github.event.pull_request.user.login == 'dependabot[bot]' || "
    + "github.event.pull_request.user.login == 'yorha-operator-6o[bot]'";
in
{
  options.github.workflows.triage = {
    enable = mkEnableOption "triage";

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
    };
  };

  config = mkIf config.github.workflows.triage.enable {
    github.settings.workflows.triage = {
      jobs.triage = {
        runs-on = "ubuntu-slim";
        steps = [
          {
            continue-on-error = true;
            id = "createGithubAppToken";
            uses = "actions/create-github-app-token@v3";
            "with" = {
              client-id = "\${{ vars.OPERATOR_APP_CLIENT_ID }}";
              private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
              permission-contents = "read";
              permission-pull-requests = "write";
            }
            // cfg.settings.create-github-app-token;
          }
          {
            uses = "shikanime-studio/actions/nix/setup@v9";
            "with" = {
              github-token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
            };
          }
          {
            uses = "shikanime-studio/actions/checkout@v9";
            "with" = {
              github-token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
            }
            // cfg.settings.checkout;
          }
          {
            "if" = mergeCondition;
            env.GITHUB_TOKEN = githubToken;
            run = "gh pr edit \"\${{ github.event.pull_request.number }}\" --add-label dependencies";
          }
          {
            "if" = ghstackCondition;
            env.GITHUB_TOKEN = githubToken;
            run = "gh pr edit \"\${{ github.event.pull_request.number }}\" --add-label ghstack";
          }
        ];
      };
      name = "Triage";
      on.pull_request.types = [
        "opened"
        "synchronize"
      ];
      permissions.pull-requests = "write";
    };
  };
}
