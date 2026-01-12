{
  imports = [
    ./base.nix
  ];

  gitignore.templates = [
    "gh:Rust"
  ];

  renovate.settings.cargo.enabled = true;

  languages.rust.enable = true;
}
