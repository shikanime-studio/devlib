{ config, lib, ... }:

with lib;

let
  cfg = config.languages.nix;
in
{
  config = mkIf cfg.enable {
    languages.nix.enable = true;
    git-hooks.hooks = {
      deadnix.enable = true;
      flake-checker.enable = true;
    };
  };
}
