{ lib, pkgs, ... }:

with lib;

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

  renovate.settings = {
    extends = [
      "config:best-practices"
      "security:openssf-scorecard"
    ];
    postUpgradeTasks.nixFmt = {
      commands = [
        "nix"
        "fmt"
      ];
      installTools.nix = { };
    };
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
          command = getExe pkgs.dyff;
          options = [
            "json"
            "--restructure"
            "--in-place"
          ];
          includes = [
            "*.json"
            "*.yaml"
            "*.yml"
          ];
        };

        formatter."dyff-yaml" = {
          command = getExe pkgs.dyff;
          options = [
            "yaml"
            "--restructure"
            "--in-place"
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
