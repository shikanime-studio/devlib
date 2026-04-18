{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.github.workflows.integration;
in
{
  options.github.workflows.integration = {
    enable = mkEnableOption "integration workflow";
  };

  config = mkIf cfg.enable {
    github.settings.workflows.integration = {
      name = "Integration";
      on.workflow_dispatch = { };
      on.workflow_call.secrets = {
        OPERATOR_PRIVATE_KEY.required = true;
        CACHIX_AUTH_TOKEN.required = false;
      };
      on = {
        pull_request = {
          branches = [
            "main"
            "gh/[0-9]+/[0-9]+/base"
          ];
          types = [
            "opened"
            "reopened"
            "synchronize"
            "ready_for_review"
          ];
        };
        push.branches = [
          "main"
          "release-[0-9]+.[0-9]+"
        ];
      };
      permissions.contents = "read";
    };
  };
}
