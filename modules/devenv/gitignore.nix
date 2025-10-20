{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.gitignore;
in
{
  options.gitignore = {
    enable = lib.mkEnableOption "gitignore generator";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.gitnr;
      description = "The gitnr package to use";
    };

    content = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "*.log"
        "dist/"
      ];
      description = ''
        Additional gitignore patterns to append to the generated file.
        These patterns will be added after the templates are processed.
      '';
    };

    templates = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "tt:linux"
        "tt:macos"
        "tt:windows"
      ];
      description = ''
        List of templates to include in the .gitignore file.

        Supported prefixes:
        - repo: - GitHub repository path (e.g., repo:github/gitignore/refs/heads/main/Nix.gitignore)
        - tt: - TopTal template (e.g., tt:go, tt:jetbrains+all)
        - gh: - GitHub template (e.g., gh:Node)
        - ghc: - GitHub community template (e.g., ghc:JavaScript/Vue)
        - url: - Remote URL (e.g., url:https://domain.com/template.gitignore)
        - file: - Local file (e.g., file:path/to/local.template.gitignore)

        Templates without prefixes default to GitHub templates.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [ cfg.package ];

    enterShell = lib.mkIf (cfg.templates != [ ] || cfg.content != [ ]) ''
      gitignoreContent=""
      ${lib.optionalString (cfg.templates != [ ]) ''
        gitignoreContent="$gitignoreContent $(${cfg.package}/bin/gitnr create ${lib.concatStringsSep " " cfg.templates} 2>/dev/null)"
      ''}
      ${lib.optionalString (cfg.content != [ ]) ''
        gitignoreContent="$gitignoreContent${
          lib.optionalString (cfg.templates != [ ]) "\n\n"
        }${lib.concatStringsSep "\n" cfg.content}"
      ''}
      echo -e "$gitignoreContent" > ${config.env.DEVENV_ROOT}/.gitignore
    '';
  };
}
