{ config, pkgs, ... }:

{
  imports = [ ./base.nix ];

  gitignore.templates = [ "tt:node" ];

  renovate.settings.npm.enabled = true;

  languages.javascript = {
    enable = true;
    corepack.enable = true;
    npm = {
      install.enable = true;
      # FIXES: https://github.com/cachix/devenv/issues/2538
      package = config.languages.javascript.package;
    };
    package = pkgs.nodejs;
  };

  treefmt.config.settings.global.excludes = [ "node_modules/*" ];
}
