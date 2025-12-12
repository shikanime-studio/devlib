{ pkgs, ... }:

{
  packages = [
    pkgs.docker
    pkgs.gnumake
    pkgs.go
    pkgs.kubectl
    pkgs.kustomize
  ];
}
