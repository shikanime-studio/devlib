{ config, ... }:

{
  git-hooks.hooks = {
    deadnix.enable = true;
    flake-checker.enable = true;
    statix.enable = true;
  };

  gitignore.templates = [
    "gh:Nix"
    "repo:shikanime-studio/gitignore/refs/heads/main/Devenv.gitignore"
  ];

  treefmt.config.programs.nixfmt.enable = true;
}
