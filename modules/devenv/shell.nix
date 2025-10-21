{ config, lib, ... }:

with lib;

let
  cfg = config.languages.shell;
in
{
  config = mkIf cfg.enable {
    git-hooks.hooks.shellcheck.enable = true;
  };
}
