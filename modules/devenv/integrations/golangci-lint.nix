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

  wrapped = pkgs.runCommand "golangci-lint-wrapped" { buildInputs = [ pkgs.makeWrapper ]; } ''
    makeWrapper ${cfg.package}/bin/golangci-lint $out/bin/golangci-lint \
      ${lib.optionalString cfg.packageOverrides.go "--prefix PATH : ${cfg.packageOverrides.go}/bin \\"}
      --append-flag --config \
      --append-flag "${yamlFormat.generate "golangci-lint.yaml" cfg.settings}"
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
