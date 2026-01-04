{ lib, pkgs, ... }:

with lib;

{
  imports = [
    ./base.nix
  ];

  cachix = {
    enable = true;
    push = "shikanime";
  };

  containers = mkForce { };

  ghstack.enable = true;

  packages = [
    pkgs.gh
    pkgs.sapling
  ];
}
