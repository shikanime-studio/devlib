{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.go;
in
{
  config = mkIf cfg.enable {
    home.sessionPath = [
      "${config.xdg.dataHome}/go/bin"
    ];

    programs.go = {
      env.GOPATH = "${config.xdg.dataHome}/go";
      telemetry.mode = "off";
    };
  };
}
