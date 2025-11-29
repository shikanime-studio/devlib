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
    git-hooks = {
      excludes = [ "vendor" ];

      hooks.gotest = {
        enable = mkDefault true;
        inherit (cfg) package;
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

    golangci-lint = {
      enable = mkDefault true;
      packageOverrides.go = cfg.package;
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

    treefmt.config.settings.global.excludes = [ "vendor/*" ];
  };
}
