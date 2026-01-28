{
  imports = [
    ./base.nix
  ];

  gitignore.templates = [ "tt:node" ];

  renovate.settings.npm.enabled = true;

  languages.javascript = {
    enable = true;
    corepack.enable = true;
    npm.install.enable = true;
  };
}
