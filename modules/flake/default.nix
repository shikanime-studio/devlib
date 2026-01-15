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
      mkMerge [
        (mkIf cfg.devenv.enable {
          devenv.modules =
            let
              treefmt = {
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
              };
            in
            [
              ../devenv/profiles/default.nix
              treefmt
            ];
        })

        (mkIf cfg.git-hooks.enable {
          pre-commit.settings =
            if builtins.hasAttr cfg.git-hooks.shell config.devenv.shells then
              config.devenv.shells.${cfg.git-hooks.shell}.git-hooks
            else
              { };
        })

        (mkIf cfg.treefmt.enable {
          treefmt =
            if builtins.hasAttr cfg.treefmt.shell config.devenv.shells then
              config.devenv.shells.${cfg.treefmt.shell}.treefmt.config
            else
              { };
        })
      ];
  };
}
