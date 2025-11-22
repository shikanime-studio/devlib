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
    git-hooks.hooks = {
      govet.enable = true;
      revive.enable = true;
      staticcheck = {
        enable = true;
        package = pkgs.runCommand "staticcheck-wrapped" { buildInputs = [ pkgs.makeWrapper ]; } ''
          makeWrapper ${pkgs.go-tools}/bin/staticcheck $out/bin/staticcheck \
            --prefix PATH : ${cfg.package}/bin
        '';
      };
    };

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
      exec = "${getExe pkgs.go} mod tidy";
    };

    treefmt.config.programs = {
      gofmt.enable = true;
      golines.enable = true;
    };
  };
}
