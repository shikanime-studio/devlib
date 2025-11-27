{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.git-hooks;
in
{
  config = mkIf (cfg.hooks != { }) {
    gitignore.content = [
      ".pre-commit-config.yaml"
    ];
  };
}
