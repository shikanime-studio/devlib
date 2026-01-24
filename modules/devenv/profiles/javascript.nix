{
  imports = [
    ./base.nix
  ];

  git-hooks.hooks.eslint.enable = true;

  gitignore.templates = [
    "tt:node"
  ];

  renovate.settings.npm.enabled = true;

  languages.javascript = {
    enable = true;
    corepack.enable = true;
    npm.install.enable = true;
  };

  treefmt.config = {
    programs.prettier.enable = true;
    settings.global.excludes = [ "node_modules/*" ];
  };
}
