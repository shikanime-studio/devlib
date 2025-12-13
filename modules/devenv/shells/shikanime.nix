{ pkgs, ... }:

{
  imports = [
    ./base.nix
  ];

  cachix = {
    enable = true;
    push = "shikanime";
  };

  containers = pkgs.lib.mkForce { };

  packages = [
    pkgs.gh
    pkgs.ghstack
    pkgs.sapling
  ];
}
