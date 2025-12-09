{ pkgs, ... }:

{
  home.packages = [
    pkgs.beam28Packages.elixir-ls
  ];

  home.sessionVariables.MIX_XDG = "1";
}
