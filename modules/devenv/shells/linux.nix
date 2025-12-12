{ pkgs, ... }:

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
    pkgs.pahole
    pkgs.pkg-config
    pkgs.python3
    pkgs.zlib
  ]
  ++ optionals pkgs.hostPlatform.isLinux [
    pkgs.elfutils
  ];
}
