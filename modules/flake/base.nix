_: _: {
  perSystem = _: {
    treefmt = {
      programs = {
        autocorrect.enable = true;
        jsonfmt.enable = true;
        mdformat.enable = true;
        taplo.enable = true;
        xmllint.enable = true;
        yamlfmt.enable = true;
      };
      settings.excludes = [
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
