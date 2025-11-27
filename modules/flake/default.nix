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
        devenv.modules = if cfg.devenv.enable then [ ../devenv/default.nix ] else [ ];

        treefmt =
          if cfg.treefmt.enable && hasAttr cfg.treefmt.shell config.devenv.shells then
            config.devenv.shells.${cfg.treefmt.shell}.treefmt.config
          else
            { };
      };
  };
}
