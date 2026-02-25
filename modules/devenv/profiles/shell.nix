{
  imports = [ ./base.nix ];

  languages.shell.enable = true;

  treefmt.config.programs = {
    shellcheck.enable = true;
    shfmt.enable = true;
  };
}
