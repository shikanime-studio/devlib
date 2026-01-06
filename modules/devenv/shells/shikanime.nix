{ pkgs, ... }:

{
  cachix = {
    enable = true;
    push = "shikanime";
  };

  containers = pkgs.lib.mkForce { };

  ghstack.enable = true;

  packages = [
    pkgs.sapling
  ];
}
