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
      inherit (inputs.automata.packages.${pkgs.stdenv.hostPlatform.system}) default;
      type = types.package;
      description = "Automata CLI package to expose in the dev shell.";
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    tasks."devlib:automata:update" = {
      description = "Run automata update";
      exec = ''
        ${getExe cfg.package} update all ${config.devenv.root}
      '';
    };
  };
}
