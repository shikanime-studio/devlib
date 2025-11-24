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

    gitignore.templates = [
      "tt:python"
    ];

    treefmt.config.programs.ruff-format.enable = mkDefault true;
  };
}
