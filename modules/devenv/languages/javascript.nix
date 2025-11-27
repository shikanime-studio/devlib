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
    gitignore.templates = [
      "tt:node"
    ];

    treefmt.config.programs.prettier.enable = mkDefault true;
  };
}
