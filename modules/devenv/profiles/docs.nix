{
  imports = [
    ./base.nix
  ];

  treefmt.config.programs = {
    autocorrect.enable = true;
    mdformat.enable = true;
  };
}
