{
  gitignore = {
    enable = true;
    content = [
      ".pre-commit-config.yaml"
    ];
  };

  tasks."devenv:treefmt:run".before = [ "devenv:enterShell" ];

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
