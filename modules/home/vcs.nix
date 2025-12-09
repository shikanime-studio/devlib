{ pkgs, ... }:

{
  home.packages = [
    pkgs.ghstack
    pkgs.sapling
  ];

  programs.gh.enable = true;
}
