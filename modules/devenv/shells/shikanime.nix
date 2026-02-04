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
      integration = {
        enable = true;
        settings.cachix-push.name = "shikanime";
      };
      release.enable = true;
      triage.enable = true;
      update.enable = true;
    };
  };
}
