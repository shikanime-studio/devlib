{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.glab;
in
{
  options.programs.glab = {
    enable = mkEnableOption "GitLab CLI (glab)";

    package = mkOption {
      type = types.package;
      default = pkgs.glab;
      description = "GitLab CLI package to install.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
