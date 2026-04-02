{
  imports = [ ./default.nix ];

  git-hooks.hooks.trufflehog.enable = true;

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
        rumdl-check.enable = true;
        rumdl-format.enable = true;
        taplo.enable = true;
        toml-sort.enable = true;
        xmllint.enable = true;
        yamlfmt.enable = true;
      };
      settings.global.excludes = [
        ".devenv/*"
        ".direnv/*"
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
