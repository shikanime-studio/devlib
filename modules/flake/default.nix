{ withSystem, ... }:
{
  config,
  inputs,
  lib,
  ...
}:

with lib;

let
  cfg = config.devlib;
in
{
  options.devlib = {
    devenv = {
      enable = mkOption {
        type = types.bool;
        default = inputs.devenv != null;
        description = "Enable devenv.";
      };
    };

    git-hooks = {
      enable = mkOption {
        type = types.bool;
        default = inputs.git-hooks != null;
        description = "Enable git-hooks git-hooks.";
      };
      shell = mkOption {
        type = types.str;
        default = "default";
        description = "The shell package to use for git-hooks and treefmt.";
      };
    };

    treefmt = {
      enable = mkOption {
        type = types.bool;
        default = inputs.treefmt-nix != null;
        description = "Enable treefmt.";
      };
      shell = mkOption {
        type = types.str;
        default = "default";
        description = "The shell package to use for treefmt.";
      };
    };
  };

  config = {
    perSystem =
      { config, system, ... }:
      {
        devenv.modules =
          if cfg.devenv.enable then
            [
              ../devenv/profiles/default.nix
              {
                treefmt.config.programs.prettier = withSystem system (
                  { config, pkgs, ... }:
                  {
                    includes = [ "*.astro" ];
                    package = pkgs.prettier.override {
                      plugins = [
                        config.packages.prettier-plugin-astro
                        config.packages.prettier-plugin-tailwindcss
                      ];
                    };
                    settings.overrides = [
                      {
                        files = "*.astro";
                        options.parser = "astro";
                      }
                    ];
                  }
                );
              }
            ]
          else
            [ ];

        pre-commit.settings =
          if cfg.git-hooks.enable && config.devenv.shells.${cfg.git-hooks.shell} != null then
            {
              inherit (config.devenv.shells.${cfg.git-hooks.shell}.git-hooks)
                default_stages
                enable
                enabledPackages
                excludes
                gitPackage
                hooks
                install
                installStages
                package
                rootSrc
                run
                shellHook
                src
                tools
                ;
            }
          else
            { };

        treefmt =
          if cfg.treefmt.enable then
            let
              # Filter out internal/computed options from programs to avoid conflicts/errors.
              treefmtPrograms = lib.mapAttrs (
                _: v: builtins.removeAttrs v [ "finalPackage" ]
              ) config.devenv.shells.${cfg.treefmt.shell}.treefmt.config.programs;

              # Keep global settings but remove generated formatter config.
              treefmtSettings =
                builtins.removeAttrs config.devenv.shells.${cfg.treefmt.shell}.treefmt.config.settings
                  [ "formatter" ];
            in
            {
              programs = treefmtPrograms;
              settings = treefmtSettings;
            }
          else
            { };
      };
  };
}
