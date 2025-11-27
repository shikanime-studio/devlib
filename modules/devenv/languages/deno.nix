{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.languages.deno;
in
{
  config = mkIf cfg.enable {
    git-hooks.hooks.denolint.enable = mkDefault true;

    gitignore.templates = [
      "tt:deno"
    ];

    treefmt.config.programs.deno.enable = mkDefault true;
  };
}
