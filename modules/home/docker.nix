{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.virtualisation.docker;
in
{
  config = mkIf (cfg.enable || cfg.rootless.enable) {
    home.sessionVariables.DOCKER_CONFIG = "${config.xdg.configHome}/docker";

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
