{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.javascript;
in
{
  options.programs.javascript = {
    enable = mkEnableOption "Node.js development environment";

    package = mkOption {
      type = types.package;
      default = pkgs.javascript;
      description = "Node.js package to install";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.typescript-language-server
      pkgs.vscode-langservers-extracted
      cfg.package
    ];

    home.sessionVariables = {
      NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
      NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm";
    };
  };
}
