{ pkgs, ... }:

{
  home.packages = [
    pkgs.beam28Packages.elixir-ls
    pkgs.elixir
    pkgs.erlang
  ];

  home.sessionVariables.MIX_XDG = "1";
}
