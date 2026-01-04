{
  config,
  lib,
  pkgs,
  ...
}:

let
  yamlFormat = pkgs.formats.yaml { };

  golangciLintConfigFile = yamlFormat.generate "golangci-lint.yaml" {
    version = 2;
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
        gocritic.enabled-tags = [
          "diagnostic"
          "experimental"
          "opinionated"
          "style"
        ];
      };
    };
    run.modules-download-mode = "vendor";
  };

  golangciLint =
    pkgs.runCommand "golangci-lint-wrapped"
      {
        buildInputs = [ pkgs.makeWrapper ];
        meta.mainProgram = "golangci-lint";
      }
      ''
        makeWrapper ${pkgs.golangci-lint}/bin/golangci-lint $out/bin/golangci-lint \
          --prefix PATH : ${config.languages.go.package}/bin \
          --add-flags "--config ${golangciLintConfigFile}"
      '';
in
{
  imports = [
    ./base.nix
  ];

  git-hooks = {
    excludes = [ "^vendor/" ];

    hooks.gotest = {
      enable = true;
      inherit (config.languages.go) package;
    };

    hooks.golangci-lint = {
      enable = true;
      package = golangciLint;
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

  languages.go.enable = true;

  tasks = {
    "devlib:go:tidy" = {
      description = "Run go mod tidy";
      exec = "${lib.getExe config.languages.go.package} mod tidy";
      execIfModified = [
        "**/*.go"
      ];
    };

    "devlib:go:vendor" = {
      before = [ "devenv:enterShell" ];
      description = "Run go mod vendor";
      exec = "${lib.getExe config.languages.go.package} mod vendor";
      execIfModified = [
        "go.sum"
      ];
    };
  };

  treefmt.config.settings.global.excludes = [ "vendor/*" ];
}
