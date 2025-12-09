{ config, ... }:

{
  home.packages = [
    pkgs.docker-compose-language-service
    pkgs.dockerfile-language-server
    pkgs.yaml-language-server
  ];

  programs.docker-cli = {
    enable = true;
    configDir = "${config.xdg.configHome}/docker";
    settings.auths = {
      "asia.gcr.io" = { };
      "eu.gcr.io" = { };
      "gcr.io" = { };
      "ghcr.io" = { };
      "us.gcr.io" = { };
    };
  };
}
