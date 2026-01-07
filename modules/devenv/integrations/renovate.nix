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
        before = [ "devlib:github:workflows:install" ];
        description = "Install renovate configuration";
        exec =
          let
            settings = cfg.settings // {
              "$schema" = "https://docs.renovatebot.com/renovate-schema.json";
            };

            file = jsonFormat.generate "config.json" settings;
          in
          ''
            if [ -d "${config.env.DEVENV_ROOT}/.github" ]; then
              cat ${file} > "${config.env.DEVENV_ROOT}/.github/renovate.json"
            else
              cat ${file} > "${config.env.DEVENV_ROOT}/renovate.json"
            fi
          '';
      };
    };
  };
}
