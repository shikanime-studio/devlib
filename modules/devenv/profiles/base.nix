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
        formatter."dyff-json" = {
          command = "${pkgs.bash}/bin/bash";
          options = [
            "-euc"
            ''
              for file in "$@"; do
                ${pkgs.dyff}/bin/dyff json --restructure --in-place "$file"
              done
            ''
            "--"
          ];
          includes = [ "*.json" ];
        };

        formatter."dyff-yaml" = {
          command = "${pkgs.bash}/bin/bash";
          options = [
            "-euc"
            ''
              for file in "$@"; do
                ${pkgs.dyff}/bin/dyff yaml --restructure --in-place "$file"
              done
            ''
            "--"
          ];
          includes = [
            "*.yaml"
            "*.yml"
          ];
        };

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
