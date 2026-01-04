{ lib, pkgs, ... }:

with lib;

{
  imports = [
    ./base.nix
  ];

  cachix = {
    enable = true;
    push = "shikanime-studio";
  };

  containers = mkForce { };

  ghstack.enable = true;

  packages = [
    pkgs.sapling
  ];
}
