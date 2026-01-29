{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.gitignore;

  templates =
    cfg.templates
    ++ optionals cfg.enableDefaultTemplates [
      "tt:jetbrains+all"
      "tt:linux"
      "tt:macos"
      "tt:vim"
      "tt:visualstudiocode"
      "tt:windows"
    ];

  contentHeader = ''
    ###-------------------###
    ###  Devlib: content  ###
    ###-------------------###
  '';

  content = concatStringsSep "\n" (
    optional (cfg.content != [ ]) ("\n" + contentHeader) ++ cfg.content
  );

  templateArgs = optionalString (
    templates != [ ]
  ) "<(${getExe cfg.package} create ${concatStringsSep " " templates})";

  contentArg = optionalString (cfg.content != [ ]) "<(${pkgs.coreutils}/bin/echo \"${content}\")";
in
{
  options.gitignore = {
    enable = mkEnableOption "gitignore generator";

    package = mkOption {
      type = types.package;
      default = pkgs.gitnr;
      description = "The gitnr package to use";
    };

    content = mkOption {
      type = types.listOf types.str;
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

    enableDefaultTemplates = mkOption {
      type = types.bool;
      default = true;
      description = "Prepend a sensible default set of TopTal templates.";
    };

    templates = mkOption {
      type = types.listOf types.str;
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

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    tasks."devlib:gitignore:install" = {
      before = [ "devenv:enterShell" ];
      description = "Generate .gitignore file";
      exec = optionalString (templates != [ ] || cfg.content != [ ]) ''
        ${pkgs.coreutils}/bin/cat \
          ${templateArgs} \
          ${contentArg} \
          > "${config.env.DEVENV_ROOT}/.gitignore"
      '';
    };
  };
}
