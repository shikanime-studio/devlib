{ config, lib, ... }:

with lib;

let
  cfg = config.languages.shell;
in
{
  config = mkIf cfg.enable {

    treefmt.config.programs = {
      shellcheck.enable = mkDefault true;
      shfmt.enable = mkDefault true;
    };
  };
}
