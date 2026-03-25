{ lib, ... }:

with lib;

{
  containers = mkForce { };

  ghstack.enable = true;

  github = {
    enable = true;
    workflows = {
      cleanup.enable = true;
      commands.enable = true;
      integration.enable = true;
      release = {
        enable = true;
        settings.cachix-push.name = "shikanime-studio";
      };
      triage.enable = true;
      update.enable = true;
    };

    settings.workflows = {
      integration.jobs.nix."with" = {
        cachix-name = "shikanime-studio";
        app-id = "\${{ vars.OPERATOR_APP_ID }}";
      };
      release.jobs.nix."with" = {
        cachix-name = "shikanime-studio";
        app-id = "\${{ vars.OPERATOR_APP_ID }}";
      };
    };
  };
}
