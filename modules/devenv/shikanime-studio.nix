{ pkgs, ... }:

{
  cachix = {
    enable = true;
    push = "shikanime-studio";
  };

  docker.enable = true;

  github.enable = true;

  gitignore.enable = true;

  languages = {
    nix.enable = true;
    shell.enable = true;
  };

  packages = [
    pkgs.gh
    pkgs.ghstack
    pkgs.sapling
  ];

  treefmt = {
    enable = true;
    config.programs.prettier.enable = true;
  };
}
