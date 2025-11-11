{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.languages.go;
in
{
  config = mkIf cfg.enable {
    gitignore = {
      content = [
        "__debug_bin*"
      ];
      templates = [
        "tt:go"
      ];
    };
    treefmt.config.programs.gofmt.enable = true;
  };
}
