{ pkgs, ... }:

{
  home.packages = [
    pkgs.ghstack
    pkgs.sapling
    pkgs.tea
    pkgs.glab
  ];

  programs.gh.enable = true;
}
