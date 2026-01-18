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

  template =
    if cfg.generate ? plugins then
      cfg.generate // { plugins = map resolvePlugin cfg.generate.plugins; }
    else
      cfg.generate;

  templateConfigFile = yamlFormat.generate "buf.gen.yaml" template;

  package = pkgs.runCommand "buf-wrapped" { buildInputs = [ pkgs.makeWrapper ]; } ''
    makeWrapper ${cfg.package}/bin/buf $out/bin/buf \
      --add-flags "--template ${templateConfigFile}"
  '';
in
{
  options.buf = {
    enable = mkEnableOption "Buf configuration generator";

    package = mkOption {
      type = types.package;
      default = pkgs.buf;
      description = "Buf CLI package to expose in the dev shell.";
    };

    template = mkOption {
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

    tasks."devlib:buf:generate" = {
      before = [ "devenv:enterShell" ] ++ optional config.treefmt.enable "devenv:treefmt:run";
      description = "Run buf generate with buf.gen.yaml";
      exec = ''
        ${getExe package} generate
      '';
    };

    treefmt.config.programs.buf.enable = mkDefault true;
  };
}
