{ pkgs, ... }:

{
  imports = [
    ./base.nix
  ];

  gitignore.templates = [
    "repo:shikanime/gitignore/refs/heads/main/Latex.gitignore"
  ];

  languages.texlive = {
    enable = true;
    base = pkgs.texliveFull;
  };
}
