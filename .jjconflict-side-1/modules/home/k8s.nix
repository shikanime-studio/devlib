{
  config,
  pkgs,
  ...
}:

let
  configDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "${config.home.homeDirectory}/Library/Application Support/skaffold"
    else
      "${config.xdg.configHome}/skaffold";
in
{
  home = {
    packages = [
      pkgs.kind
      pkgs.kubectl
      pkgs.kubernetes-helm
      pkgs.kustomize
      pkgs.skaffold
    ];

    sessionVariables.SKAFFOLD_CONFIG = "${configDir}/config";
  };
}
