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
    git-hooks.hooks.tflint.enable = true;
    gitignore.templates = [
      "tt:terraform"
    ];
    treefmt.config.programs.terraform.enable = true;
  };
}
