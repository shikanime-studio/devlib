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
        actions.cachix-push."with".name = "shikanime";
      };
      triage.enable = true;
      update.enable = true;
    };
  };
}
