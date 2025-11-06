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
    gitignore.templates = [
      "tt:deno"
    ];
  };
}
