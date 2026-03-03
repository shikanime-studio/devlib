{ pkgs, ... }:

{
  imports = [ ./base.nix ];

  gitignore.templates = [ "tt:node" ];

  renovate.settings.npm.enabled = true;

  languages.javascript = {
    enable = true;
    corepack.enable = true;

    npm.install = {
      enable = true;
      # FIXES: https://github.com/cachix/devenv/issues/2538
      package = pkgs.nodejs-slim;
    };
  };

  treefmt.config.settings.global.excludes = [ "node_modules/*" ];
}
