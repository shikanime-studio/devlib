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

    generate = mkOption {
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
          managed = { enabled = true; };
          plugins = [
            {
              plugin = "buf.build/protocolbuffers/go";
              out = "gen/go";
            }
            {
              package = pkgs.protoc-gen-go;
              plugin = "go";
              out = "gen/go";
            }
          ];
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    files = let
      resolvePlugin = pluginCfg:
        if pluginCfg ? package then
          (lib.removeAttrs pluginCfg [ "package" ]) // {
            path = getExe pluginCfg.package;
          }
        else
          pluginCfg;

      generateResolved =
        if cfg.generate ? plugins then
          cfg.generate // { plugins = map resolvePlugin cfg.generate.plugins; }
        else
          cfg.generate;
    in {
      "buf.gen.yaml".yaml = generateResolved;
    };

    gitignore.content = [
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
