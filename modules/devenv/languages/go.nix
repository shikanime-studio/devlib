{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.languages.go;
in
{
  config = mkIf cfg.enable {
    git-hooks.hooks.govet.enable = true;

    gitignore = {
      content = [
        "__debug_bin*"
      ];
      templates = [
        "tt:go"
      ];
    };

    tasks."devlib:go:tidy" = {
      description = "Run go mod tidy";
      before = [ "devenv:enterShell" ];
      exec = "${pkgs.lib.getExe pkgs.go} mod tidy";
    };

    treefmt.config.programs = {
      gofmt.enable = true;
      golines.enable = true;
    };
  };
}
