{
  config,
  lib,
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

    tasks = mkIf cfg.python.uv.enable {
      "devlib:python:uv:sync" = {
        after = [ "devlib:python:uv:tidy" ];
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
