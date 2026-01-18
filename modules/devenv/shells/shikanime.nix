{ lib, ... }:

with lib;

{
  containers = mkForce { };

  ghstack.enable = true;

  github.actions.cachix-push."with".name = "shikanime";
}
