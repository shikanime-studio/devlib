{
  imports = [
    ./base.nix
  ];

  git-hooks.hooks.clippy.enable = true;

  gitignore.templates = [
    "gh:Rust"
  ];

  renovate.settings.cargo.enabled = true;

  languages.rust.enable = true;

  treefmt.config.programs.rustfmt.enable = true;
}
