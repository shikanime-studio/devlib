{ pkgs, ... }:

{
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
