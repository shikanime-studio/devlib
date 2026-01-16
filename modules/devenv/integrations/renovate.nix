{
  pkgs,
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.renovate;

  jsonFormat = pkgs.formats.json { };

  settings = cfg.settings // {
    "$schema" = "https://docs.renovatebot.com/renovate-schema.json";
  };

  configFile = jsonFormat.generate "config.json" settings;
in
{
  options.renovate = mkOption {
    type = types.submodule {
      options = {
        enable = mkEnableOption "enable renovate";

        settings = mkOption {
          type = types.submodule {
            freeformType = jsonFormat.type;
          };
          default = { };
          description = "Renovate settings";
        };
      };
    };

    default = { };

    description = ''
      Renovate configuration.
    '';
  };

  config = mkIf cfg.enable {
    tasks = {
      "devlib:renovate:install" = {
        before = [
          "devenv:enterShell"
        ]
        ++ optional config.treefmt.enable "devenv:treefmt:run";
        description = "Install renovate configuration";
        exec =
          if config.github.enable then
            ''
              mkdir -p "${config.env.DEVENV_ROOT}/.github"
              cat ${configFile} > "${config.env.DEVENV_ROOT}/.github/renovate.json"
            ''
          else
            ''
              cat ${configFile} > "${config.env.DEVENV_ROOT}/renovate.json"
            '';
      };
    };
  };
}
