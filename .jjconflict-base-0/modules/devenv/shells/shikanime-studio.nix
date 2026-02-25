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
  };
}
