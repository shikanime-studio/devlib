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
      release.enable = true;
      triage.enable = true;
      update.enable = true;
    };

    settings.workflows.integration.jobs.nix."with"."cachix-name" = "shikanime-studio";
    settings.workflows.release.jobs.nix."with"."cachix-name" = "shikanime-studio";
  };

  renovate.enable = true;
}
