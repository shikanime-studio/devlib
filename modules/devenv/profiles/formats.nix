{
  imports = [
    ./base.nix
  ];

  treefmt.config.programs = {
    prettier.enable = true;
    taplo.enable = true;
    xmllint.enable = true;
  };
}
