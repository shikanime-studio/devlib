{ pkgs, ... }:

{
  containers = pkgs.lib.mkForce { };

  packages = [
    pkgs.bc
    pkgs.bison
    pkgs.elfutils
    pkgs.flex
    pkgs.gnumake
    pkgs.ncurses
    pkgs.openssl
    pkgs.pkg-config
    pkgs.python3
    pkgs.zlib
  ];
}
