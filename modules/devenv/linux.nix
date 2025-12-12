{
  containers = pkgs.lib.mkForce { };

  packages = [
    pkgs.bc
    pkgs.bison
    pkgs.flex
    pkgs.elfutils
    pkgs.ncurses
    pkgs.openssl
    pkgs.pkg-config
    pkgs.python3
    pkgs.zlib
  ];
}
