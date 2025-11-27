{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.languages.rust;
in
{
  config = mkIf cfg.enable {
    gitignore.templates = [
      "gh:Rust"
    ];

    treefmt.config.programs.rustfmt.enable = mkDefault true;
  };
}
