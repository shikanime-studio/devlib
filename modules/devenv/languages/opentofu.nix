{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.languages.opentofu;
in
{
  config = mkIf cfg.enable {
    gitignore.templates = [
      "tt:terraform"
    ];

    treefmt.config.programs = {
      hclfmt.enable = mkDefault true;
      terraform.enable = mkDefault true;
    };
  };
}
