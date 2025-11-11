{ config, lib, ... }:

with lib;

let
  cfg = config.devlib;
in
{
  options.devlib = {
    pre-commit.shell = mkOption {
      type = types.str;
      default = "default";
      description = "Shell name to read pre-commit git-hooks configuration from.";
    };

    treefmt.shell = mkOption {
      type = types.str;
      default = "default";
      description = "Shell name to read treefmt configuration from.";
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
        devenv.modules = [ ../devenv/default.nix ];
        pre-commit.settings = (getShell cfg.pre-commit.shell).git-hooks;
        treefmt = (getShell cfg.treefmt.shell).treefmt.config;
      };
  };
}
