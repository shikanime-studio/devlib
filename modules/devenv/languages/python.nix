{ config, lib, ... }:

with lib;

{
  git-hooks.hooks.ruff.enable = true;

  gitignore.templates = [
    "tt:python"
  ];

  tasks = {
    "devlib:python:uv:sync" = {
      before = [ "devenv:enterShell" ];
      description = "Sync python dependencies";
      exec = "${getExe pkgs.uv} sync";
      execIfModified = [ "uv.lock" ];
    };
  };

  treefmt.config.programs.ruff-format.enable = true;
}
