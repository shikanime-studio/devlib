{ lib, ... }:

with lib;

{
  cachix = {
    enable = true;
    push = "shikanime";
  };

  containers = mkForce { };

  ghstack.enable = true;

  github.actions.cachix-push."with".name = "shikanime";
}
