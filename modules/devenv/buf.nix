{
  pkgs,
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.buf;
  yamlFormat = pkgs.formats.yaml { };
in
{
  options.buf = {
    enable = mkEnableOption "Buf configuration generator";

    package = mkOption {
      type = types.package;
      default = pkgs.buf;
      description = "Buf CLI package to expose in the dev shell.";
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = yamlFormat.type;
      };
      default = {
        version = "v2";
      };
      description = "Contents of buf.yaml.";
      example = literalExpression ''
        {
          version = "v2";
          deps = [ "buf.build/googleapis/googleapis" ];
          breaking = { use = [ "FILE" ]; };
          lint = { use = [ "DEFAULT" ]; };
        }
      '';
    };

    gen = mkOption {
      type = types.submodule {
        freeformType = yamlFormat.type;
      };
      default = {
        version = "v2";
        plugins = [ ];
      };
      description = "Contents of buf.gen.yaml.";
      example = literalExpression ''
        {
          version = "v2";
          managed = {
            enabled = true;
          };
          plugins = [
            {
              plugin = "buf.build/protocolbuffers/go";
              out = "gen/go";
            }
            {
              plugin = "buf.build/grpc/go";
              out = "gen/go";
            }
          ];
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    files = {
      "buf.yaml".yaml = cfg.settings;
      "buf.gen.yaml".yaml = cfg.gen;
    };

    gitignore.content = [
      "buf.yaml"
      "buf.gen.yaml"
    ];

    tasks."devlib:buf:generate" = {
      description = "Run buf generate with buf.gen.yaml";
      before = [ "devenv:enterShell" ];
      exec = ''
        ${lib.getExe cfg.package} generate
      '';
    };
  };
}
