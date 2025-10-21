{ lib, ... }:

with lib;

{
  options.sapling = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Sapling";
    };
  };

  config = mkIf config.sapling.enable {
    packages = [ pkgs.sapling ];
  };
}
