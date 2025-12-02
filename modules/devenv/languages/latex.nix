{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.languages.latex;
in
{
  options.languages.latex = {
    enable = mkEnableOption "latex";

    package = mkOption {
      type = types.package;
      default = pkgs.texlive.combined.scheme-full;
      description = "The latex package to use.";
    };
  };
  config = mkIf cfg.enable {
    git-hooks.hooks.chktex.enable = mkDefault true;

    gitignore.templates = [
      "repo:shikanime/gitignore/refs/heads/main/Latex.gitignore"
    ];

    packages = [ cfg.package ];

    treefmt.config.programs.latexindent.enable = true;
  };
}
