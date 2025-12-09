{ pkgs, ... }:

{
  home.packages = [
    pkgs.basedpyright
    pkgs.python312Packages.jedi-language-server
  ];
}
