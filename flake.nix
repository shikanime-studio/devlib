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
        devenvModule = ./modules/devenv/shells/default.nix;
        devenvModules = {
          default = ./modules/devenv/shells/default.nix;
          docker = ./modules/devenv/profiles/docker.nix;
          elixir = ./modules/devenv/profiles/elixir.nix;
          go = ./modules/devenv/profiles/go.nix;
          javascript = ./modules/devenv/profiles/javascript.nix;
          linux = ./modules/devenv/shells/linux.nix;
          longhorn = ./modules/devenv/shells/longhorn.nix;
          nix = ./modules/devenv/profiles/nix.nix;
          nixos = ./modules/devenv/profiles/nixos.nix;
          python = ./modules/devenv/profiles/python.nix;
          rust = ./modules/devenv/profiles/rust.nix;
          shell = ./modules/devenv/profiles/shell.nix;
          shikanime = ./modules/devenv/shells/shikanime.nix;
          k8s = ./modules/devenv/profiles/k8s.nix;
          yaml = ./modules/devenv/profiles/yaml.nix;
        };

        homeManagerModule = ./modules/home/default.nix;
        homeManagerModules = {
          default = ./modules/home/default.nix;
          docker = ./modules/home/docker.nix;
          elixir = ./modules/home/elixir.nix;
          go = ./modules/home/go.nix;
          javascript = ./modules/home/javascript.nix;
          nix = ./modules/home/nix.nix;
          python = ./modules/home/python.nix;
          rust = ./modules/home/rust.nix;
          shell = ./modules/home/shell.nix;
          k8s = ./modules/home/k8s.nix;
          yaml = ./modules/home/yaml.nix;
          vcs = ./modules/home/vcs.nix;
        };

        flakeModule = ./modules/flake/default.nix;

        templates = {
          default = {
            path = ./templates/default;
            description = "A devenv template with default settings.";
          };
          remote = {
            path = ./templates/remote;
            description = "A simple direnv with remote flake.";
          };
        };
      };
      perSystem =
        { pkgs, ... }:
        {
          devenv.shells = {
            default.imports = [
              ./modules/devenv/profiles/docs.nix
              ./modules/devenv/profiles/formats.nix
              ./modules/devenv/profiles/github.nix
              ./modules/devenv/profiles/nix.nix
              ./modules/devenv/profiles/shell.nix
              ./modules/devenv/shells/default.nix
            ];
            linux.imports = [
              ./modules/devenv/shells/linux.nix
            ];
            longhorn.imports = [
              ./modules/devenv/shells/longhorn.nix
            ];
            nixos.imports = [
              ./modules/devenv/shells/nixos.nix
            ];
            shikanime.imports = [
              ./modules/devenv/shells/shikanime.nix
            ];
          };
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
