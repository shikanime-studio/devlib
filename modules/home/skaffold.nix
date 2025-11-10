{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.skaffold;
in
{
  options.programs.skaffold = {
    enable = mkEnableOption "Skaffold";

    package = mkOption {
      type = types.package;
      default = pkgs.skaffold;
      description = "Skaffold package to install";
    };

    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Skaffold configuration settings";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."skaffold/config" = mkIf (cfg.settings != {}) {
      text = builtins.toJSON cfg.settings;
    };

    home.sessionVariables.SKAFFOLD_CONFIG = "${config.xdg.configHome}/skaffold/config";
  };
}
