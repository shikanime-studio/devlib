{
  config,
  inputs,
  lib,
  self,
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
        description = "Shell name to read git-hooks git-hooks configuration from.";
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
        description = "Shell name to read treefmt configuration from.";
      };
    };
  };

  config = {
    perSystem =
      { config, pkgs, ... }:
      {
        devenv.modules =
          if cfg.devenv.enable then
            [
              ../devenv/default.nix
              {
                treefmt.config.programs.prettier.settings.pluginSearchDirs = [
                  "${self.packages.${pkgs.stdenv.hostPlatform.system}.prettier-plugin-astro}/lib"
                  "${self.packages.${pkgs.stdenv.hostPlatform.system}.prettier-plugin-tailwindcss}/lib"
                ];
              }
            ]
          else
            [ ];

        pre-commit.settings =
          if cfg.git-hooks.enable && hasAttr cfg.git-hooks.shell config.devenv.shells then
            config.devenv.shells.${cfg.git-hooks.shell}.git-hooks
          else
            { };

        treefmt =
          if cfg.treefmt.enable && hasAttr cfg.treefmt.shell config.devenv.shells then
            config.devenv.shells.${cfg.treefmt.shell}.treefmt.config
          else
            { };
      };
  };
}
