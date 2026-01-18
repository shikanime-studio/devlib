{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.docker
    pkgs.docker-compose-language-service
    pkgs.dockerfile-language-server
  ];

  programs = {
    docker-cli = {
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

    nushell.extraConfig = ''
      use ${pkgs.nu_scripts}/share/nu_scripts/modules/docker *
    '';
  };
}
