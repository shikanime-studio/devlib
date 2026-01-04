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

    tasks."devlib:ghstack:hooks:install" = {
      before = [ "devenv:enterShell" ];
      description = "Install ghstack pre-ghstack hook";
      exec =
        let
          hookScript = pkgs.writeScript "pre-ghstack" ''
            #!${pkgs.bashNonInteractive}/bin/bash

            ${getExe config.git-hooks.package} run --from-ref "$1" --to-ref "$2"
          '';
        in
        ''
          install -D -m 0755 ${hookScript} .git/hooks/pre-ghstack
        '';
    };
  };
}
