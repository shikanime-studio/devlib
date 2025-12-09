{
  config,
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.skaffold
  ];

  home.sessionVariables.SKAFFOLD_CONFIG = "${config.xdg.configHome}/skaffold/config";
}
