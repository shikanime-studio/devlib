{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.languages.python;
in
{
  config = mkIf cfg.enable {
    git-hooks.hooks.ruff.enable = mkDefault true;

    treefmt.config.programs.ruff-format.enable = mkDefault true;
  };
}
