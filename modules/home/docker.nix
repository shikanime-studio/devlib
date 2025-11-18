{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.dokcer-cli;
in
{
  config = mkIf cfg.enable {
    programs.docker-cli.configDir = "${config.xdg.configHome}/docker";

    xdg.configFile."docker/config.json".source =
      let
        format = pkgs.formats.json { };
      in
      format.generate "config.json" {
        auths = {
          "ghcr.io" = { };
        };
        credsStore = "secretservice";
      };
  };
}
