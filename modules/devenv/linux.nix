{ pkgs, ... }:

{
  imports = [
    ./base.nix
  ];

  packages = [
    pkgs.bc
    pkgs.bison
    pkgs.elfutils
    pkgs.flex
    pkgs.gcc
    pkgs.gnumake
    pkgs.ncurses
    pkgs.openssl
    pkgs.pahole
    pkgs.pkg-config
    pkgs.python3
    pkgs.zlib
  ];
}
