{ pkgs, ... }:

{
  docker.enable = true;

  languages.go.enable = true;

  packages = [
    pkgs.docker
    pkgs.gnumake
    pkgs.kubectl
    pkgs.kustomize
  ];
}
