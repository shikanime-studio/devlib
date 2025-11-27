{ config, ... }:

{
  git-hooks.hooks.shellcheck.enable = true;

  treefmt.config.programs.shfmt.enable = true;
}
