{
  pkgs,
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.sops;

  yamlFormat = pkgs.formats.yaml { };

  configFile = yamlFormat.generate "sops.yaml" cfg.settings;

  wrapped =
    pkgs.runCommand "sops-wrapped"
      {
        buildInputs = [ pkgs.makeWrapper ];
        meta.mainProgram = "sops";
      }
      ''
        makeWrapper ${cfg.package}/bin/sops $out/bin/sops \
          ${lib.optionalString (cfg.settings != { }) ''
            --add-flag --config \
            --add-flag "${configFile}"
          ''}
      '';
in
{
  options.sops = {
    enable = mkEnableOption "Sops configuration generator";

    package = mkOption {
      type = types.package;
      default = pkgs.sops;
      description = "Sops CLI package to expose in the dev shell.";
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = yamlFormat.type;
      };
      default = { };
      description = "SOPS YAML configuration passed via --config";
    };
  };

  config = mkIf cfg.enable {
    packages = [ wrapped ];

    tasks = {
      "devenv:treefmt:run".after = [ "devlib:sops:updatekeys" ];

      "devlib:sops:updatekeys" = {
        before = [ "devenv:enterShell" ];
        description = "Run sops updatekeys";
        exec = ''
          ${getExe pkgs.findutils} . -type f -name "*.enc.*" -exec ${getExe wrapped} updatekeys --yes {} +
        '';
        execIfModified = [
          "**/*.enc.*"
        ];
      };
    };

    treefmt.config.programs = {
      prettier.enable = mkDefault true;
      taplo.enable = mkDefault true;
    };
  };
}
