{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  configDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/docker"
    else
      "${removePrefix config.home.homeDirectory config.xdg.configHome}/docker";
in
{
  home.packages = [
    pkgs.docker-compose-language-service
    pkgs.dockerfile-language-server
  ];

  programs = {
    docker-cli = {
      inherit configDir;
      enable = true;
      settings.auths = {
        "asia.gcr.io" = { };
        "eu.gcr.io" = { };
        "gcr.io" = { };
        "ghcr.io" = { };
        "us.gcr.io" = { };
      };
    };

    nushell.extraConfig = ''
      use ${pkgs.nu_scripts}/share/nu_scripts/modules/docker *
    '';
  };
}
