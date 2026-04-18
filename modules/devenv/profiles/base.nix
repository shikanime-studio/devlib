{ pkgs, ... }:

let
  jsonFormat = pkgs.formats.json { };

  configFile = jsonFormat.generate ".oxfmtrc.json" {
    printWidth = 80;
    proseWrap = "always";
  };
in
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
        oxfmt.enable = true;
        rumdl-check.enable = true;
        xmllint.enable = true;
      };
      settings = {
        formatter.oxfmt = {
          includes = [
            "*.toml"
          ];
          options = [
            "--config"
            (toString configFile)
          ];
        };
        global.excludes = [
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
  };
}
