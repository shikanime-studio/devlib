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
    tasks."go:tidy" = {
      exec = "${getExe cfg.package} mod tidy";
      execIfModified = [
        "*.go"
        "go.mod"
        "go.sum"
      ];
    };
    treefmt.config.programs = {
      gofmt.enable = true;
      golines.enable = true;
    };
  };
}
