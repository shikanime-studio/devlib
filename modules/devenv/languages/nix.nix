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
    git-hooks.hooks = {
      deadnix.enable = mkDefault true;
      flake-checker.enable = mkDefault true;
      statix.enable = mkDefault true;
    };

    gitignore.templates = [
      "gh:Nix"
      "repo:shikanime-studio/gitignore/refs/heads/main/Devenv.gitignore"
    ];

    treefmt.config.programs.nixfmt.enable = mkDefault true;
  };
}
