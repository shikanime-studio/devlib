{ config, lib, ... }:

with lib;

let
  cfg = config.programs.go;
in
{
  config = mkIf cfg.enable {
    go.env.GOPATH = "${config.xdg.dataHome}/go";
  };
}
