{
  lib,
  pkgs,
  ...
}:

with lib;

{
  cachix = {
    enable = true;
    push = "shikanime-studio";
  };

  containers = mkForce { };

  ghstack.enable = true;

  packages = [
    pkgs.sapling
  ];
}
