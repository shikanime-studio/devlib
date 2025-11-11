{
  inputs = {
    devenv.url = "github:cachix/devenv";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks.url = "github:cachix/git-hooks.nix";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  nixConfig = {
    extra-public-keys = [
      "shikanime.cachix.org-1:OrpjVTH6RzYf2R97IqcTWdLRejF6+XbpFNNZJxKG8Ts="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
    extra-substituters = [
      "https://shikanime.cachix.org"
      "https://devenv.cachix.org"
    ];
  };

  outputs =
    inputs@{
      devenv,
      flake-parts,
      git-hooks,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        devenv.flakeModule
        git-hooks.flakeModule
        treefmt-nix.flakeModule
        ./modules/flake/default.nix
      ];
      flake = {
        devenvModule = ./modules/devenv/default.nix;
        homeManagerModule = ./modules/home/default.nix;
        flakeModule = ./modules/flake/default.nix;
      };
      perSystem =
        { pkgs, ... }:
        {
          devenv.shells.default = {
            git-hooks.enable = true;
            containers = pkgs.lib.mkForce { };
            languages = {
              nix.enable = true;
              shell.enable = true;
            };
            cachix = {
              enable = true;
              push = "shikanime";
            };
            github.enable = true;
            gitignore = {
              enable = true;
              enableDefaultTemplates = true;
            };
            packages = [
              pkgs.sapling
            ];
            treefmt = {
              enable = true;
              config = {
                enableDefaultExcludes = true;
                programs.prettier.enable = true;
                settings.global.excludes = [
                  "LICENSE"
                ];
              };
            };
          };
        };
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
}
