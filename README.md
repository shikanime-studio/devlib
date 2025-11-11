# Devlib

Devlib is a collection of Nix flake modules that bootstrap a consistent,
reproducible developer experience using `devenv` and `flake-parts`. It provides
declarative generators for common development workflows and config files.

- Provides `flake.devenvModule` for plug-and-play integration.
- Modules:
  - `air` — Generates `.air.toml` and installs `pkgs.air` for Go hot-reload.
  - `github` — Declaratively generates GitHub Actions workflows under
    `.github/workflows/`.
  - `gitignore` — Builds `.gitignore` from templates and custom content via
    `gitnr`.

## Prerequisites

- `nix` with flakes enabled and recent version (recommended `nix >= 2.18`).
- `devenv` (flakes module), `direnv` optional but recommended.
- Optional: `nu` if you plan to run `update.nu`.

## Quick Start (Consumer)

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

Use the flake module to route formatting and Git hooks settings from a chosen `devenv.shell` into top-level `treefmt` and `pre-commit` outputs.

- Add the module to imports: `inputs.devlib.flakeModule`.
- Configure `devlib` options to select the source shell and enable features.

Example:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devenv.url = "github:cachix/devenv";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    git-hooks.url = "github:cachix/git-hooks.nix";
    devlib.url = "github:shikanime-studio/devlib";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks.flakeModule
        inputs.devlib.flakeModule
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
