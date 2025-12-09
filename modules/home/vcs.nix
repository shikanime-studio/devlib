{ pkgs, ... }:

{
  home.packages = [
    pkgs.gh
    pkgs.ghstack
    pkgs.sapling
  ];
}
