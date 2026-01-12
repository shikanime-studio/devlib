{
  inputs = {
    devenv = {
      url = "github:cachix/devenv";
      inputs = {
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
        nixpkgs.follows = "nixpkgs";
      };
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      self,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { flake-parts-lib, self', ... }:
      with flake-parts-lib;
      let
        flakeModule = importApply ./modules/flake/default.nix { };

        flakeModules = {
          default = flakeModule;
          base = importApply ./modules/flake/base.nix { };
          docker = importApply ./modules/flake/docker.nix { };
          docs = importApply ./modules/flake/docs.nix { };
          elixir = importApply ./modules/flake/elixir.nix { };
          formats = importApply ./modules/flake/formats.nix { };
          git = importApply ./modules/flake/git.nix { };
          go = importApply ./modules/flake/go.nix { };
          javascript = importApply ./modules/flake/javascript.nix { };
          nix = importApply ./modules/flake/nix.nix { };
          ocaml = importApply ./modules/flake/ocaml.nix { };
          opentofu = importApply ./modules/flake/opentofu.nix { };
          python = importApply ./modules/flake/python.nix { };
          rust = importApply ./modules/flake/rust.nix { };
          shell = importApply ./modules/flake/shell.nix { };
          texlive = importApply ./modules/flake/texlive.nix { };
        };
      in
      {
        imports = [
          devenv.flakeModule
          flake-parts.flakeModules.easyOverlay
          flakeModules.base
          flakeModule
          flakeModules.docs
          flakeModules.formats
          flakeModules.git
          flakeModules.nix
          flakeModules.shell
          git-hooks.flakeModule
          treefmt-nix.flakeModule
        ];
        flake = {
          devenvModule = ./modules/devenv/default.nix;
          devenvModules = {
            default = self'.flake.devenvModule;
            docker = ./modules/devenv/profiles/docker.nix;
            docs = ./modules/devenv/profiles/docs.nix;
            elixir = ./modules/devenv/profiles/elixir.nix;
            formats = ./modules/devenv/profiles/formats.nix;
            git = ./modules/devenv/profiles/git.nix;
            github = ./modules/devenv/profiles/github.nix;
            go = ./modules/devenv/profiles/go.nix;
            javascript = ./modules/devenv/profiles/javascript.nix;
            nix = ./modules/devenv/profiles/nix.nix;
            ocaml = ./modules/devenv/profiles/ocaml.nix;
            opentofu = ./modules/devenv/profiles/opentofu.nix;
            python = ./modules/devenv/profiles/python.nix;
            rust = ./modules/devenv/profiles/rust.nix;
            shell = ./modules/devenv/profiles/shell.nix;
            shikanime = ./modules/devenv/shells/shikanime.nix;
            shikanime-studio = ./modules/devenv/shells/shikanime-studio.nix;
            texlive = ./modules/devenv/profiles/texlive.nix;
          };

          homeManagerModule = ./modules/home/default.nix;
          homeManagerModules = {
            default = self'.flake.homeManagerModule;
            docker = ./modules/home/docker.nix;
            elixir = ./modules/home/elixir.nix;
            go = ./modules/home/go.nix;
            javascript = ./modules/home/javascript.nix;
            k8s = ./modules/home/k8s.nix;
            nix = ./modules/home/nix.nix;
            python = ./modules/home/python.nix;
            rust = ./modules/home/rust.nix;
            shell = ./modules/home/shell.nix;
            typst = ./modules/home/typst.nix;
            unix = ./modules/home/unix.nix;
            vcs = ./modules/home/vcs.nix;
            yaml = ./modules/home/yaml.nix;
          };

          inherit flakeModule flakeModules;

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
            devenv.shells.default.imports = [
              self.devenvModules.docs
              self.devenvModules.formats
              self.devenvModules.git
              self.devenvModules.github
              self.devenvModules.nix
              self.devenvModules.shell
              self.devenvModules.shikanime-studio
            ];
            packages = {
              fleet = pkgs.callPackage ./pkgs/fleet { };
              bootloose = pkgs.callPackage ./pkgs/bootloose { };
              longhornctl = pkgs.callPackage ./pkgs/longhornctl { };
              prettier-plugin-astro = pkgs.callPackage ./pkgs/prettier-plugin-astro { };
              prettier-plugin-tailwindcss = pkgs.callPackage ./pkgs/prettier-plugin-tailwindcss { };
            };
          };
        systems = [
          "x86_64-linux"
          "x86_64-darwin"
          "aarch64-linux"
          "aarch64-darwin"
        ];
      }
    );
}
