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

  # ghstack requires python
  languages.python.enable = mkDefault true;

  packages = [
    pkgs.ghstack
    pkgs.sapling
  ];
}
