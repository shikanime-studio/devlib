{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.languages.nix;
in
{
  config = mkIf cfg.enable {
    gitignore.templates = [
      "gh:Nix"
      "repo:shikanime-studio/gitignore/refs/heads/main/Devenv.gitignore"
    ];

    treefmt.config.programs = {
      deadnix.enable = mkDefault true;
      nixfmt.enable = mkDefault true;
      statix.enable = mkDefault true;
    };
  };
}
