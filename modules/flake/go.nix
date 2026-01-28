_: _: {
  perSystem =
    { pkgs, ... }:
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
              --prefix PATH : ${pkgs.go}/bin \
              --add-flags "--config ${golangciLintConfigFile}"
          '';
    in
    {
      pre-commit.settings = {
        excludes = [ "^vendor/" ];

        hooks.gotest = {
          enable = true;
          package = pkgs.go;
        };

        hooks.golangci-lint = {
          enable = true;
          package = golangciLint;
        };
      };

      treefmt.settings.global.excludes = [ "vendor/*" ];
    };
}
