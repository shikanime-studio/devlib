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
    git-hooks.hooks.gotest = {
      enable = mkDefault true;
      inherit (cfg) package;
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
        description = "Download go dependencies";
        exec = "${getExe cfg.package} mod download";
        execIfModified = [
          "go.sum"
        ];
      };

      "devlib:go:tidy" = {
        description = "Run go mod tidy";
        exec = "${getExe cfg.package} mod tidy";
      };
    };
  };
}
