{
  imports = [
    ./base.nix
  ];

  git-hooks.hooks.shellcheck.enable = true;

  languages.shell.enable = true;

  treefmt.config.programs.shfmt.enable = true;
}
