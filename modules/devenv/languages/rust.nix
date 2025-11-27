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
    git-hooks.hooks.clippy.enable = mkDefault true;

    gitignore.templates = [
      "gh:Rust"
    ];

    treefmt.config.programs.rustfmt.enable = mkDefault true;
  };
}
