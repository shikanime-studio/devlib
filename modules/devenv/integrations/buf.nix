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

  resolvePlugin =
    pluginCfg:
    if pluginCfg ? package then
      let
        exe = getExe pluginCfg.package;
      in
      (removeAttrs pluginCfg [
        "package"
        "plugin"
        "remote"
      ])
      // {
        local = exe;
      }
    else
      pluginCfg;

  genResolved =
    if cfg.generate ? plugins then
      cfg.generate // { plugins = map resolvePlugin cfg.generate.plugins; }
    else
      cfg.generate;
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
              # Remote plugin
              plugin = "buf.build/protocolbuffers/go";
              out = "gen/go";
            }
            {
              # Local plugin resolved from a Nix package
              package = pkgs.protoc-gen-go;
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
      "buf.gen.yaml".yaml = genResolved;
    };

    gitignore.content = [
      "buf.gen.yaml"
    ];

    tasks = {
      "devlib:buf:generate" = {
        description = "Run buf generate with buf.gen.yaml";
        before = [ "devenv:enterShell" ];
        exec = ''
          ${getExe cfg.package} generate
        '';
      };
      "devenv:treefmt:run".after = [ "devlib:buf:generate" ];
    };

    treefmt.config.programs.buf.enable = mkDefault true;
  };
}
