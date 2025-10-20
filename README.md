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

## Module: gitignore

Generate `.gitignore` using prebuilt template sources and your own additions.

- Options:
  - `gitignore.enable`: boolean
  - `gitignore.package`: package providing `gitnr` (default `pkgs.gitnr`)
  - `gitignore.templates`: list of template refs (supports `repo:`, `tt:`,
    `gh:`, `ghc:`, `url:`, `file:`)
  - `gitignore.content`: list of raw patterns appended after templates

Example:

```nix
devenv.shells.default = {
  gitignore.enable = true;
  gitignore.templates = [
    "repo:github/gitignore/refs/heads/main/Nix.gitignore"
    "tt:jetbrains+all"
    "tt:linux"
    "tt:macos"
    "tt:vim"
    "tt:visualstudiocode"
    "tt:windows"
  ];
  gitignore.content = [
    "*.log"
    "dist/"
  ];
};
```

- Writes to `.gitignore` on shell entry.
- Uses `gitnr` behind the scenes to compose templates.

## Module: github (Workflows Generator)

Declaratively define GitHub Actions workflows in Nix; files are emitted to
`.github/workflows/*.yaml`.

- Options:
  - `github.enable`: boolean
  - `github.workflows.<name>.settings`: freeform YAML expressed via a Nix
    attrset

Example:

```nix
devenv.shells.default = {
  github.enable = true;

  github.workflows.check.settings = {
    name = "Check";
    on = {
      push.branches = [ "main" ];
      pull_request.branches = [ "main" ];
    };
    jobs = {
      check = {
        runs-on = "ubuntu-latest";
        steps = [
          { uses = "actions/checkout@v5"; }
          {
            uses = "DeterminateSystems/nix-installer-action@v19";
            with.github-token = "${{ secrets.NIX_GITHUB_TOKEN }}";
          }
          { uses = "DeterminateSystems/magic-nix-cache-action@v13"; }
          {
            name = "Check Nix Flake";
            run = "nix flake check --all-systems --no-pure-eval --accept-flake-config";
          }
        ];
      };
    };
  };
};
```

- Creates/updates workflow files on shell entry.
- Each attribute under `workflows` becomes a separate YAML file.

## Module: air (Go Live Reload)

Installs and configures [Air](https://github.com/cosmtrek/air) for hot-reloading
Go apps.

- Options:
  - `air.enable`: boolean
  - `air.package`: Air package (default `pkgs.air`)
  - `air.settings`: freeform TOML configuration

Example:

```nix
devenv.shells.default = {
  air.enable = true;

  air.settings = {
    root = ".";
    build = {
      bin = "tmp/main";
      cmd = "go build -o tmp/main .";
      include = [ "**/*.go" "**/*.tpl" "**/*.tmpl" "**/*.html" ];
      exclude = [ "assets/**" "tmp/**" "vendor/**" ];
    };
    log = { time = true; };
    misc = { clean_on_exit = true; };
  };
};
```

- Writes `.air.toml` to repo root on shell entry.
- Air can be invoked with `air` inside the dev shell.

## Using devlib in this repository

This repository’s `flake.nix` wires `devenv` and `treefmt-nix` for formatting,
Git hooks, and caching:

- `treefmt-nix` configures `nixfmt`, `prettier`, `shfmt`, and `statix`.
- `devenv.shells.default.packages` adds `gh` and `sapling` to the dev shell.
- `nixConfig.extra-substituters` includes caches for faster builds.

Open a dev shell with:

```bash
nix develop
```

If using `direnv`, the included `.envrc` automatically loads the flake
environment:

```bash
direnv allow
```

## Update Helpers

A helper script exists to refresh `.gitignore` and workflows:

```bash
nu ./update.nu
```

- Requires `nu` inside the dev shell (`nix develop`).
- Prints progress and writes updated files into your repo.

## License

Licensed under the GNU AGPL v3. See `LICENSE` for details.
