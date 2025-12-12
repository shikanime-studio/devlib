{ pkgs, ... }:

{
  git-hooks.hooks = {
    golangci-lint.enable = true;
    gotest.enable = true;
  };

  languages.go.enable = true;

  packages = [
    pkgs.docker
    pkgs.gnumake
    pkgs.kubectl
    pkgs.kustomize
  ];
}
