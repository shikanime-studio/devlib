{ config, ... }:

{
  git-hooks.hooks.eslint.enable = true;

  gitignore.templates = [ "tt:node" ];

  treefmt.config.programs.prettier.enable = true;
}
