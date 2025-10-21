{ lib, ... }:

with lib;

let
  cfg = config.sapling;
in
{
  options.sapling = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Sapling";
    };
  };

  config = mkIf cfg.enable {
    packages = [ pkgs.sapling ];
  };
}
