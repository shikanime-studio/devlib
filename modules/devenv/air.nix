{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.air;
  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate ".air.toml" cfg.settings;
in
{
  options.air = {
    enable = lib.mkEnableOption "Air live reload for Go applications";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.air;
      defaultText = lib.literalExpression "pkgs.air";
      description = ''
        The Air package to use.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = settingsFormat.type;

        options = {
          tmp_dir = lib.mkOption {
            type = lib.types.str;
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

      example = lib.literalExpression ''
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

  config = lib.mkIf cfg.enable {
    packages = [ cfg.package ];

    enterShell = ''
      mkdir -p "${cfg.settings.tmp_dir}"
      cat ${configFile} > ${config.env.DEVENV_ROOT}/.air.toml
    '';
  };
}
