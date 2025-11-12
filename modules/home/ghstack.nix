{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.ghstack;
in
{
  options.programs.ghstack = {
    enable = mkEnableOption "ghstack";

    package = mkOption {
      type = types.package;
      default = pkgs.ghstack;
      description = "The ghstack package to use.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.sessionVariables = {
      GHSTACKRC_PATH = "${config.xdg.configHome}/ghstack/ghstackrc";
    };
  };
}
