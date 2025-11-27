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
      govet.enable = mkDefault false;
      revive.enable = mkDefault false;
      staticcheck = {
        enable = mkDefault false;
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

    tasks = {
      "devlib:go:download" = {
        after = [ "devlib:go:tidy" ];
        before = [ "devenv:enterShell" ];
        description = "Download go dependencies";
        exec = "${getExe pkgs.go} mod download";
        execIfModified = [
          "go.sum"
        ];
      };

      "devlib:go:tidy" = {
        before = [ "devenv:enterShell" ];
        description = "Run go mod tidy";
        exec = "${getExe pkgs.go} mod tidy";
      };

      "devlib:go:vendor" = {
        before = [ "devenv:enterShell" ];
        description = "Run go mod vendor";
        exec = "${getExe pkgs.go} mod vendor";
        execIfModified = [
          "go.sum"
        ];
      };
    };

    treefmt.config = {
      programs = {
        gofmt.enable = mkDefault true;
        golines.enable = mkDefault true;
        prettier.excludes = [ "vendor/*" ];
      };
    };
  };
}
