{ lib, ... }:

with lib;

{
  imports = [ ../integrations/ghstack.nix ];

  cachix = {
    enable = true;
    push = "shikanime-studio";
  };

  containers = mkForce { };

  ghstack.enable = true;
}
