{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.glab;
in
{
  config = mkIf cfg.enable {
    git.settings.credential."https://gitlab.com".helper = "${getExe pkgs.glab} auth git-credential";
  };
}
