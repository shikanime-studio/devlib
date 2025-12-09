{
  config,
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.kustomize
    pkgs.skaffold
  ];

  home.sessionVariables.SKAFFOLD_CONFIG = "${config.xdg.configHome}/skaffold/config";
}
