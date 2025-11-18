{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.docker-cli;
in
{
  config = mkIf cfg.enable {
    programs.docker-cli = {
      configDir = "${config.xdg.configHome}/docker";
      settings = {
        auths = {
          "asia.gcr.io" = { };
          "eu.gcr.io" = { };
          "gcr.io" = { };
          "ghcr.io" = { };
          "us.gcr.io" = { };
        };
        credsStore = "secretservice";
      };
    };
  };
}
