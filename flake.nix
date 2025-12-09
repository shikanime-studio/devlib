{
  inputs = {
    automata.url = "github:shikanime-studio/automata";
    devenv.url = "github:cachix/devenv";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks.url = "github:cachix/git-hooks.nix";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  nixConfig = {
    extra-substituters = [
      "https://cachix.cachix.org"
      "https://devenv.cachix.org"
      "https://shikanime.cachix.org"
      "https://shikanime-studio.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "shikanime.cachix.org-1:OrpjVTH6RzYf2R97IqcTWdLRejF6+XbpFNNZJxKG8Ts="
      "shikanime-studio.cachix.org-1:KxV6aDFU81wzoR9u6pF1uq0dQbUuKbodOSP8/EJHXO0="
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
        devenvModules.shikanime-studio = ./modules/devenv/shikanime-studio.nix;

        homeManagerModules = {
          default = ./modules/home/default.nix;
          beam = ./modules/home/beam.nix;
          docker = ./modules/home/docker.nix;
          go = ./modules/home/go.nix;
          javascript = ./modules/home/javascript.nix;
          nix = ./modules/home/nix.nix;
          python = ./modules/home/python.nix;
          rustup = ./modules/home/rustup.nix;
          shell = ./modules/home/shell.nix;
          skaffold = ./modules/home/skaffold.nix;
          yaml = ./modules/home/yaml.nix;
        };

        flakeModule = ./modules/flake/default.nix;

        templates = {
          default = {
            path = ./templates/default;
            description = "A direnv supported Nix flake with devenv integration.";
          };
          shikanime-studio = {
            path = ./templates/shikanime-studio;
            description = "A direnv supported Nix flake with devenv integration for shikanime-studio.";
          };
        };
      };
      perSystem =
        { pkgs, ... }:
        {
          devenv.shells.default.imports = [
            ./modules/devenv/shikanime-studio.nix
          ];
          packages = {
            fleet = pkgs.callPackage ./pkgs/fleet { };
            bootloose = pkgs.callPackage ./pkgs/bootloose { };
            longhornctl = pkgs.callPackage ./pkgs/longhornctl { };
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
