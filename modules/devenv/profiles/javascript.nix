{
  imports = [ ./base.nix ];

  gitignore.templates = [ "tt:node" ];

  renovate.settings.npm.enabled = true;

  languages.javascript = {
    enable = true;
    corepack.enable = true;
    pnpm = {
      enable = true;
      install.enable = true;
    };
  };

  treefmt.config.settings.global.excludes = [ "node_modules/*" ];
}
