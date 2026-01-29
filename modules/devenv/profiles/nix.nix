{
  imports = [ ./base.nix ];

  git-hooks.hooks.flake-checker.enable = true;

  gitignore.templates = [
    "repo:shikanime-studio/gitignore/refs/heads/main/Devenv.gitignore"
  ];

  languages.nix.enable = true;

  renovate.settings.nix.enabled = true;

  treefmt.config.programs = {
    deadnix.enable = true;
    nixfmt.enable = true;
    statix.enable = true;
  };
}
