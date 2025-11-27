{ config, ... }:

{
  git-hooks.hooks.clippy.enable = true;

  gitignore.templates = [
    "gh:Rust"
  ];

  treefmt.config.programs.rustfmt.enable = true;
}
