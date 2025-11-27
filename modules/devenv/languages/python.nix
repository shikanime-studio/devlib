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

    treefmt.config.programs= {
      ruff-check.enable = true;
      ruff-format.enable = mkDefault true;
    };
  };
}
