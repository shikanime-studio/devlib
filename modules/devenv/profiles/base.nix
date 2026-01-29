{
  imports = [ ./default.nix ];

  gitignore = {
    enable = true;
    content = [ ".pre-commit-config.yaml" ];
  };

  treefmt = {
    enable = true;
    config = {
      programs = {
        autocorrect.enable = true;
        jsonfmt.enable = true;
        mdformat.enable = true;
        taplo.enable = true;
        xmllint.enable = true;
        yamlfmt.enable = true;
      };
      settings.global.excludes = [
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
  };
}
