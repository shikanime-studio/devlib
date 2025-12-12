{
  imports = [
    ./base.nix
  ];

  git-hooks.hooks.clippy.enable = true;

  gitignore.templates = [
    "gh:Rust"
  ];

  languages.rust.enable = true;

  treefmt.config.programs.rustfmt.enable = true;
}
