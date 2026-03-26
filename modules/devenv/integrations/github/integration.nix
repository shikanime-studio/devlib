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
      on.pull_request = {
        branches = [
          "main"
          "gh/*/*/base"
        ];
        types = [
          "opened"
          "reopened"
          "synchronize"
          "ready_for_review"
        ];
      };
      permissions.contents = "read";
    };
  };
}
