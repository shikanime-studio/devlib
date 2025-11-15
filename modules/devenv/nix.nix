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
      deadnix.enable = true;
      flake-checker.enable = true;
      statix.enable = true;
    };

    gitignore.templates = [
      "gh:Nix"
      "repo:shikanime-studio/gitignore/refs/heads/main/Devenv.gitignore"
    ];

    treefmt.config.programs.nixfmt.enable = true;
  };
}
