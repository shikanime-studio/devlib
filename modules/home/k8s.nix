{
  config,
  pkgs,
  ...
}:

{
  home = {
    packages = [
      pkgs.kind
      pkgs.kubectl
      pkgs.kubernetes-helm
      pkgs.kustomize
      pkgs.skaffold
    ];

    sessionVariables.SKAFFOLD_CONFIG = "${config.xdg.configHome}/skaffold/config";
  };
}
