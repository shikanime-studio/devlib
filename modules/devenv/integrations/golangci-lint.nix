{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.golangci-lint;

  yamlFormat = pkgs.formats.yaml { };

  go = cfg.packageOverrides.go or pkgs.go;

  configFile = yamlFormat.generate "golangci-lint.yaml" cfg.settings;

  wrapped =
    pkgs.runCommand "golangci-lint-wrapped"
      {
        buildInputs = [ pkgs.makeWrapper ];
        meta.mainProgram = "golangci-lint";
      }
      ''
        makeWrapper ${cfg.package}/bin/golangci-lint $out/bin/golangci-lint \
          --prefix PATH : ${go}/bin \
          ${lib.optionalString (cfg.settings != { }) ''
            --add-flag --config \
            --add-flag "${configFile}"
          ''}
      '';
in
{
  options.golangci-lint = {
    enable = mkEnableOption "Enable golangci-lint integration";

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = yamlFormat.type;
      };
      default = { };
      description = "golangci-lint YAML settings";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.golangci-lint;
      description = "Base golangci-lint package to wrap";
    };

    packageOverrides.go = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Override Go toolchain PATH for golangci-lint wrapper";
    };
  };

  config = mkIf cfg.enable {
    git-hooks.hooks.golangci-lint = {
      enable = true;
      package = wrapped;
    };
  };
}
