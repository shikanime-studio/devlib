{
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.docker;
in
{
  options.docker = {
    enable = mkEnableOption "docker development tools";
  };

  config = mkIf cfg.enable {
    treefmt.config.programs.dockerfmt.enable = mkDefault true;
  };
}
