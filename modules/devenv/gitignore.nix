{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.gitignore;

  templates =
    (lib.optionals cfg.enableDefaultTemplates [
      "tt:jetbrains+all"
      "tt:linux"
      "tt:macos"
      "tt:vim"
      "tt:visualstudiocode"
      "tt:windows"
    ])
    ++ cfg.templates;

  header = ''
    ###-------------------###
    ###  Devlib: content  ###
    ###-------------------###
  '';

  renderGitnr = { package, templates }: lib.optionalString (templates != [ ]) ''
    gitignoreContent="$gitignoreContent $(${package}/bin/gitnr create ${lib.concatStringsSep " " templates} 2>/dev/null)"
  '';

  renderContent = { header, content, templates }: lib.optionalString (content != [ ]) ''
    gitignoreContent="$gitignoreContent${
      lib.optionalString (templates != [ ]) "\n\n"
    }${header}\n${lib.concatStringsSep "\n" content}"
  '';
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

    enableDefaultTemplates = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Prepend a sensible default set of TopTal templates.";
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

    enterShell = lib.mkIf (templates != [ ] || cfg.content != [ ]) ''
      gitignoreContent=""
      ${renderGitnr { package = cfg.package; templates = templates; }}
      ${renderContent { header = header; content = cfg.content; templates = templates; }}
      echo -e "$gitignoreContent" > ${config.env.DEVENV_ROOT}/.gitignore
    '';
  };
}
