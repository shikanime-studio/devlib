{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.languages.go;

  yamlFormat = pkgs.formats.yaml { };

  settings = {
    version = 2;
    linters = {
      enable = [
        "bodyclose"
        "dogsled"
        "dupl"
        "durationcheck"
        "exhaustive"
        "gocritic"
        "godot"
        "gomoddirectives"
        "goprintffuncname"
        "govet"
        "importas"
        "ineffassign"
        "makezero"
        "misspell"
        "nakedret"
        "nilerr"
        "noctx"
        "nolintlint"
        "prealloc"
        "predeclared"
        "revive"
        "rowserrcheck"
        "sqlclosecheck"
        "staticcheck"
        "tparallel"
        "unconvert"
        "unparam"
        "unused"
        "wastedassign"
        "whitespace"
      ];
      settings = {
        misspell.locale = "US";
        gocritic = {
          enabled-tags = [
            "diagnostic"
            "experimental"
            "opinionated"
            "style"
          ];
          disabled-checks = [
            "importShadow"
            "unnamedResult"
          ];
        };
      };
    };
    formatters = {
      enable = [
        "gci"
        "gofmt"
        "gofumpt"
        "goimports"
      ];
      settings.gci.sections = [
        "standard"
        "default"
        "localmodule"
      ];
    };
  };

  package = pkgs.runCommand "golangci-lint-wrapped" { buildInputs = [ pkgs.makeWrapper ]; } ''
    makeWrapper ${pkgs.golangci-lint}/bin/golangci-lint $out/bin/golangci-lint \
      --prefix PATH : ${cfg.package}/bin \
      --append-flag --config \
      --append-flag "${yamlFormat.generate "golangci-lint.yaml" settings}"
  '';
in
{
  config = mkIf cfg.enable {
    git-hooks.hooks = {
      golangci-lint = {
        inherit package;
        enable = true;
      };

      hadolint.excludes = [ "^vendor/" ];

      shellcheck.excludes = [ "^vendor/" ];
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

    treefmt.config.settings.global.excludes = [ "vendor/*" ];
  };
}
