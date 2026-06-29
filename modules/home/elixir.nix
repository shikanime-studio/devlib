{ pkgs, ... }:

{
  home.packages = [
    pkgs.beamPackages.elixir-ls
    pkgs.beamPackages.elixir
    pkgs.beamPackages.erlang
  ];

  home.sessionVariables.MIX_XDG = "1";
}
