{ inputs, ... }:
{
  config,
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

      git-hooks = {
        enable = mkOption {
          type = types.bool;
          default = inputs.git-hooks != null;
          description = "Enable git-hooks.";
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
  };

  config = {
    perSystem =
      { config, ... }:
      mkMerge [
        (mkIf cfg.devenv.enable {
          devenv.modules = [
            ../devenv/profiles/default.nix
          ]
          ++ optional cfg.devenv.git-hooks.enable {
            pre-commit = {
              inherit (config.pre-commit.settings) hooks excludes;
            };
          }
          ++ optional cfg.devenv.treefmt.enable {
            treefmt.config = {
              inherit (config.treefmt) settings;
            };
          };
        })
      ];
  };
}
