{ config, ... }:

{
  git-hooks.hooks = {
    deadnix.enable = true;
    flake-checker.enable = true;
    statix.enable = true;
  };

  gitignore.templates = [ "tt:terraform" ];

  treefmt.config.programs = {
    hclfmt.enable = true;
    terraform.enable = true;
  };
}
