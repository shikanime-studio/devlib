{
  imports = [
    ./base.nix
  ];

  git-hooks.hooks.flake-checker.enable = true;

  gitignore.templates = [
    "gh:Nix"
    "repo:shikanime-studio/gitignore/refs/heads/main/Devenv.gitignore"
  ];

  languages.nix.enable = true;

  treefmt.config.programs = {
    deadnix.enable = true;
    nixfmt.enable = true;
    statix.enable = true;
  };
}
