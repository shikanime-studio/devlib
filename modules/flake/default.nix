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
    };

    treefmt = {
      enable = mkOption {
        type = types.bool;
        default = inputs.treefmt-nix != null;
        description = "Enable treefmt.";
      };
    };
  };

  config = {
    perSystem =
      { config, final, ... }:
      {
        devenv.modules =
          if cfg.devenv.enable then
            [
              ../devenv/default.nix
              {
                treefmt.config.programs.prettier.settings.pluginSearchDirs = [
                  "${final.prettier-plugin-astro}/lib"
                  "${final.prettier-plugin-tailwindcss}/lib"
                ];
              }
            ]
          else
            [ ];

        overlayAttrs = {
          inherit (config.packages) prettier-plugin-astro prettier-plugin-tailwindcss;
        };

        pre-commit.settings =
          if cfg.git-hooks.enable then
            mkMerge (mapAttrsToList (_: shell: shell.git-hooks) config.devenv.shells)
          else
            { };

        treefmt =
          if cfg.treefmt.enable then
            mkMerge (mapAttrsToList (_: shell: shell.treefmt.config) config.devenv.shells)
          else
            { };
      };
  };
}
