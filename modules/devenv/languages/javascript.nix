{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.languages.javascript;
in
{
  config = mkIf cfg.enable {
    git-hooks.hooks.eslint.enable = mkDefault true;

    gitignore.templates = [
      "tt:node"
    ];

    treefmt.config.programs.prettier.enable = mkDefault true;
  };
}
