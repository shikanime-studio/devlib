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
      { config, ... }:
      {
        devenv.modules =
          if cfg.devenv.enable then
            [
              ../devenv/default.nix
              ../devenv/languages/go.nix
              ../devenv/languages/javascript.nix
              ../devenv/languages/nix.nix
              ../devenv/languages/opentofu.nix
              ../devenv/languages/python.nix
              ../devenv/languages/rust.nix
              ../devenv/languages/shell.nix
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
