{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.rustup;
in
{
  options.programs.rustup = {
    enable = mkEnableOption "rustup";

    package = mkOption {
      type = types.package;
      default = pkgs.rustup;
      description = "The rustup package to use.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.sessionPath = [
      "${config.xdg.configHome}/cargo/bin"
    ];

    home.sessionVariables = {
      CARGO_HOME = "${config.xdg.configHome}/cargo";
      RUSTUP_HOME = "${config.xdg.configHome}/rustup";
    };
  };
}
