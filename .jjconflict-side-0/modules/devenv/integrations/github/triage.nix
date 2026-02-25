{
  config,
  lib,
  pkgs,
  ...
}:
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
    enable = lib.mkEnableOption "triage";

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

  config = lib.mkIf config.github.workflows.triage.enable {
    github.settings.workflows.triage = {
      jobs.triage = {
        runs-on = "ubuntu-slim";
        steps = [
          {
            continue-on-error = true;
            id = "createGithubAppToken";
            uses = "actions/create-github-app-token@v2";
            "with" = {
              app-id = "\${{ vars.OPERATOR_APP_ID }}";
              private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
              permission-contents = "read";
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
            env = {
              GITHUB_TOKEN = githubToken;
              PR_NUMBER = "\${{ github.event.pull_request.number }}";
            };
            "if" = mergeCondition;
            run = "gh pr edit \"$PR_NUMBER\" --add-label dependencies";
          }
          {
            env = {
              GITHUB_TOKEN = githubToken;
              PR_NUMBER = "\${{ github.event.pull_request.number }}";
            };
            "if" = ghstackCondition;
            run = "gh pr edit \"$PR_NUMBER\" --add-label ghstack";
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
