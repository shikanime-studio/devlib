{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.nodejs;
in
{
  options.programs.nodejs = {
    enable = mkEnableOption "Node.js development environment";

    package = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Node.js packages to install";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.sessionVariables = {
      NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
      NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm";
    };
  };
}
