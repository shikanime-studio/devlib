{
  config,
  lib,
  ...
}:

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
    enable = true;
    packageOverrides.go = config.languages.go.package;
    settings = {
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
