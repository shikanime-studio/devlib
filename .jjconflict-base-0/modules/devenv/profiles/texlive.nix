{ pkgs, ... }:

{
  imports = [
    ./base.nix
  ];

  git-hooks.hooks.chktex.enable = true;

  gitignore.templates = [
    "repo:shikanime/gitignore/refs/heads/main/Latex.gitignore"
  ];

  languages.texlive = {
    enable = true;
    base = pkgs.texliveFull;
  };

  treefmt.config.programs.latexindent.enable = true;
}
