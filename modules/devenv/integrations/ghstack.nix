{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.ghstack;
in
{
  options.ghstack = {
    enable = mkEnableOption "ghstack";

    package = mkOption {
      type = types.package;
      default = pkgs.ghstack;
      description = "The ghstack package to use.";
    };
  };

  config = mkIf cfg.enable {
    languages.python.enable = mkDefault true;

    packages = [ cfg.package ];

    files.".git/hooks/pre-ghstack".text = ''
      #!${pkgs.bashNonInteractive}/bin/bash

      ${getExe config.git-hooks.package} hook-impl \
        --config ${config.git-hooks.configFile} \
        --hook-dir ${config.env.DEVENV_ROOT}/.git/hooks \
        --hook-type pre-push \
        -- \
       "$@"
    '';
  };
}
