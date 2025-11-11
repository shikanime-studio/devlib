{ config, lib, ... }:

with lib;

let
  cfg = config.programs.go;
in
{
  config = mkIf cfg.enable {
    home.sessionPath = [
      "${config.home.homeDirectory}/.local/share/go/bin"
    ];

    programs.go.env.GOPATH = "${config.xdg.dataHome}/go";
  };
}
