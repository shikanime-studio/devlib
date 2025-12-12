{ pkgs, ... }:

{
  imports = [
    ./base.nix
  ];

  cachix = {
    enable = true;
    push = "shikanime-studio";
  };

  containers = pkgs.lib.mkForce { };

  packages = [
    pkgs.gh
    pkgs.ghstack
    pkgs.sapling
  ];
}
