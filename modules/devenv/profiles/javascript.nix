{
  imports = [
    ./base.nix
  ];

  git-hooks.hooks.eslint.enable = true;

  gitignore.templates = [
    "tt:node"
  ];

  languages.javascript = {
    enable = true;
    corepack.enable = true;
  };
}
