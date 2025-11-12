# Devlib

Devlib is a collection of Nix flake modules that bootstrap a consistent,
reproducible developer experience using `devenv`, `git-hooks` and `treefmt`. It
provides declarative generators for common development workflows and config
files.

## Quick Start

Add devlib to your flake and hook up the provided `devenvModule`.

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devenv.url = "github:cachix/devenv";
    devlib.url = "github:shikanime-studio/devlib";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devenv.flakeModule ];

      perSystem = { pkgs, ... }: {
        devenv = {
          modules = [ inputs.devlib.devenvModule ];
          shells.default = {
            # Enable individual modules (see sections below)
            gitignore.enable = true;
            github.enable = true;
            air.enable = true;

            # Optional: packages in your dev shell
            packages = [ pkgs.gh pkgs.sapling ];
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
```

- Start a shell: `nix develop`
- If using `direnv`, allow the environment: `direnv allow`
- Enable or configure modules under `devenv.shells.default`.

## Flake Module

Use the flake module to route formatting and Git hooks settings from a chosen
`devenv.shell` into top-level `treefmt` and `pre-commit` outputs.

- Add the module to imports: `inputs.devlib.flakeModule`.
- Configure `devlib` options to select the source shell and enable features.

Example:

```nix
{
  inputs = {
    devenv.url = "github:cachix/devenv";
    devlib.url = "github:shikanime-studio/devlib";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks.url = "github:cachix/git-hooks.nix";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
        inputs.devlib.flakeModule
        inputs.git-hooks.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      perSystem = { pkgs, ... }: {
        devlib = {
          devenv.enable = true;
          git-hooks = {
            enable = true;
            shell = "default";
          };
          treefmt = {
            enable = true;
            shell = "default";
          };
        };
      };

      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
    };
}
```
