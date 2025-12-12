{ pkgs, ... }:

{
  imports = [
    ../integrations/air.nix
    ../integrations/automata.nix
    ../integrations/buf.nix
    ../integrations/golangci-lint.nix
    ../integrations/git-hooks.nix
    ../integrations/github.nix
    ../integrations/gitignore.nix
    ../integrations/sops.nix
  ];

  containers = pkgs.lib.mkForce { };

  treefmt.config.settings.global.excludes = [
    "*.assetsignore"
    "*.dockerignore"
    "*.gcloudignore"
    "*.gif"
    "*.ico"
    "*.jpg"
    "*.png"
    "*.svg"
    "*.txt"
    "*.webp"
  ];
}
