{ lib, pkgs, ... }:

with lib;

{
  imports = [
    ./base.nix
  ];

  languages.c.enable = true;

  packages = [
    pkgs.bc
    pkgs.bison
    pkgs.flex
    pkgs.gcc
    pkgs.gnumake
    pkgs.ncurses
    pkgs.openssl
    pkgs.pkg-config
    pkgs.python3
    pkgs.zlib
  ]
  ++ optional (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.elfutils) pkgs.elfutils
  ++ optional (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.pahole) pkgs.pahole;
}
