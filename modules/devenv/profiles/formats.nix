{
  imports = [
    ./base.nix
  ];

  treefmt.config.programs = {
    jsonfmt.enable = true;
    taplo.enable = true;
    xmllint.enable = true;
    yamlfmt.enable = true;
  };
}
