{ config, lib, ... }:

with lib;

let
  cfg = config.devlib;
in
{
  options.devlib = {
    devenv = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable devenv.";
      };
    };

    pre-commit = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable pre-commit git-hooks.";
      };
      shell = mkOption {
        type = types.str;
        default = "default";
        description = "Shell name to read pre-commit git-hooks configuration from.";
      };
    };

    treefmt = {
      enable = mkOption {
        type = types.bool;
        default = true;
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
      let
        inherit (config.devenv) shells;
        getShell = name: if hasAttr name shells then shells.${name} else shells.default;
      in
      {
        devenv.modules =
          if cfg.devenv.enable then
            [ ../devenv/default.nix ]
          else
            [ ];

        pre-commit.settings =
          if cfg.pre-commit.enable then
            (getShell cfg.pre-commit.shell).git-hooks
          else
            { };

        treefmt =
          if cfg.treefmt.enable then
            (getShell cfg.treefmt.shell).treefmt.config
          else
            { };
      };
  };
}
