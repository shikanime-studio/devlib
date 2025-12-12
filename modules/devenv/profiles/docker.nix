{
  imports = [
    ./base.nix
  ];

  git-hooks.hooks.hadolint.enable = true;

  treefmt.config.programs.dockerfmt.enable = true;
}
