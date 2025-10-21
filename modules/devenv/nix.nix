{ config, lib, ... }:

with lib;

let
  cfg = config.languages.nix;
in
{
  config = mkIf cfg.enable {
    git-hooks.hooks = {
      deadnix.enable = true;
      flake-checker.enable = true;
    };
    gitignore.templates = [
      "repo:github/gitignore/refs/heads/main/Nix.gitignore"
      "repo:shikanime/gitignore/refs/heads/main/Devenv.gitignore"
    ];
  };
}
