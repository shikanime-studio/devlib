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
    git-hooks.hooks.hadolint.enable = true;

    treefmt.config.programs.dockerfmt.enable = true;
  };
}
