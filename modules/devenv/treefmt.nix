{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.treefmt;
in
{
  config = mkIf cfg.enable {
    treefmt.config.settings.global.excludes = [
      "LICENSE"
    ];
  };
}
