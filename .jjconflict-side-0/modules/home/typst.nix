{ pkgs, ... }:

{
  home.packages = [
    pkgs.tinymist
    pkgs.typst
  ];
}
