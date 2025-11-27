{ config, lib, ... }:

with lib;

{
  git-hooks.hooks = {
    hadolint.excludes = [ "^vendor/" ];

    shellcheck.excludes = [ "^vendor/" ];

    golangci-lint.excludes = [ "^vendor/" ];
  };

  gitignore = {
    content = [ "__debug_bin*" ];
    templates = [ "tt:go" ];
  };

  golangci-lint = {
    enable = true;
    packageOverrides.go = config.languages.go.package;
  };

  tasks = {
    "devlib:go:download" = {
      after = [ "devlib:go:tidy" ];
      before = [ "devenv:enterShell" ];
      description = "Download go dependencies";
      exec = "${getExe pkgs.go} mod download";
      execIfModified = [ "go.sum" ];
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
      execIfModified = [ "go.sum" ];
    };
  };

  treefmt.config.settings.global.excludes = [ "vendor/*" ];
}
