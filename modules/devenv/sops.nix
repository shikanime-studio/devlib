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
in
{
  options.sops = {
    enable = mkEnableOption "Sops configuration generator";

    package = mkOption {
      type = types.package;
      default = pkgs.sops;
      description = "Sops CLI package to expose in the dev shell.";
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    tasks = {
      "devenv:treefmt:run".after = [ "devlib:sops:updatekeys" ];
      "devlib:sops:updatekeys" = {
        description = "Run sops updatekeys";
        before = [ "devenv:enterShell" ];
        exec = ''
          for f in *.enc.*; do
            ${getExe cfg.package} updatekeys "$f"
          done
        '';
      };
    };

    treefmt.config.programs = {
      prettier.enable = true;
      taplo.enable = true;
    };
  };
}
