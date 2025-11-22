{
  pkgs,
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.air;
  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate ".air.toml" cfg.settings;
in
{
  options.air = {
    enable = mkEnableOption "Air live reload for Go applications";

    package = mkOption {
      type = types.package;
      default = pkgs.air;
      defaultText = literalExpression "pkgs.air";
      description = ''
        The Air package to use.
      '';
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = settingsFormat.type;

        options = {
          tmp_dir = mkOption {
            type = types.str;
            readOnly = true;
            default = config.env.DEVENV_STATE + "/air/tmp";
            description = ''
              The directory to store temporary files.
            '';
          };
        };
      };

      default = { };

      description = ''
        Air configuration settings.
      '';

      example = literalExpression ''
        {
          root = ".";
          build = {
            bin = "tmp/main";
            cmd = "go build -o tmp/main .";
            include = [ "**/*.go" "**/*.tpl" "**/*.tmpl" "**/*.html" ];
            exclude = [ "assets/**" "tmp/**" "vendor/**" ];
          };
          color = {
            main = "magenta";
            watcher = "cyan";
            build = "yellow";
            runner = "green";
          };
          log = {
            time = true;
          };
          misc = {
            clean_on_exit = true;
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    enterShell = ''
      mkdir -p "${cfg.settings.tmp_dir}"
      cat ${configFile} > ${config.env.DEVENV_ROOT}/.air.toml
    '';

    gitignore.content = [
      ".air.toml"
    ];
  };
}
