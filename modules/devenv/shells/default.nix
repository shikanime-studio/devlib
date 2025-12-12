{ pkgs, ... }:

{
  imports = [
    ./base.nix
  ];

  cachix = {
    enable = true;
    push = "shikanime-studio";
  };

  packages = [
    pkgs.gh
    pkgs.ghstack
    pkgs.sapling
  ];
}
