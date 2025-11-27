{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.automata;
in
{
  options.automata = {
    enable = mkEnableOption "Automata configuration generator";

    package = mkOption {
      type = types.package;
      default = inputs.automata.packages.${pkgs.system}.default;
      description = "Automata CLI package to expose in the dev shell.";
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    tasks = {
      "devlib:automata:update" = {
        description = "Run automata update";
        exec = ''
          ${getExe cfg.package} update all
        '';
      };
      "devenv:treefmt:run".after = [ "devlib:automata:update" ];
    };
  };
}
