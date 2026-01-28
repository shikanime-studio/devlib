{
  config,
  lib,
  ...
}:

{
  imports = [
    ./base.nix
  ];

  gitignore = {
    content = [ "__debug_bin*" ];
    templates = [ "tt:go" ];
  };

  renovate.settings.gomod.enabled = true;

  languages.go.enable = true;

  tasks = {
    "devlib:go:tidy" = {
      description = "Run go mod tidy";
      exec = "${lib.getExe config.languages.go.package} mod tidy";
      execIfModified = [ "**/*.go" ];
    };

    "devlib:go:vendor" = {
      before = [ "devenv:enterShell" ];
      description = "Run go mod vendor";
      exec = "${lib.getExe config.languages.go.package} mod vendor";
      execIfModified = [ "go.sum" ];
    };
  };
}
