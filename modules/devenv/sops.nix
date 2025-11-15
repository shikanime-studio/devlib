{
  pkgs,
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.sops;
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
      "devlib:sops:updatekeys" = {
        description = "Run sops updatekeys";
        before = [ "devenv:enterShell" ];
        exec = ''
          ${getExe findutils} . -type f -name "*.enc.*" -print0 | while IFS= read -r -d ''' f; do
            ${getExe cfg.package} updatekeys "$f"
          done
        '';
      };
      "devenv:treefmt:run".after = [ "devlib:sops:updatekeys" ];
    };

    treefmt.config.programs = {
      prettier.enable = true;
      taplo.enable = true;
    };
  };
}
