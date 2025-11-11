{
  config,
  lib,
  pkgs,
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
      nix-fmt = {
        enable = true;
        name = "nix-fmt";
        description = "Format Nix files using the formatter specified in your flake.";
        package = pkgs.nix;
        entry = "${lib.getExe pkgs.nix} fmt";
      };
    };
    gitignore.templates = [
      "gh:Nix"
      "repo:shikanime-studio/gitignore/refs/heads/main/Devenv.gitignore"
    ];
  };
}
