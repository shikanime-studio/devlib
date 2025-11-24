{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.languages.python;
in
{
  config = mkIf cfg.enable {
    git-hooks.hooks.ruff.enable = mkDefault true;

    gitignore.templates = [
      "tt:python"
    ];

    tasks = mkIf cfg.uv.enable {
      "devlib:python:uv:sync" = {
        before = [ "devenv:enterShell" ];
        description = "Sync python dependencies";
        exec = "${getExe pkgs.uv} sync";
        execIfModified = [
          "pyproject.toml"
          "uv.lock"
        ];
      };
    };

    treefmt.config.programs.ruff-format.enable = mkDefault true;
  };
}
