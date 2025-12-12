{
  imports = [
    ../integrations/gitignore.nix
  ];

  gitignore = {
    enable = true;
    content = [
      ".pre-commit-config.yaml"
    ];
  };

  treefmt = {
    enable = true;
    config.settings.global.excludes = [
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
  };
}
