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
    makeWrapper ${pkgs.golangci-lint}/bin/golangci-lint $out/bin/golangci-lint \
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
  };

  config = mkIf cfg.enable {
    git-hooks.hooks.golangci-lint = {
      enable = true;
      package = wrapped;
    };
  };
}
