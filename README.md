# Devlib

Devlib is a collection of Nix flake modules that bootstrap a consistent,
reproducible developer experience using `devenv`, `git-hooks` and `treefmt`. It
provides declarative generators for common development workflows and config
files.

## What You Get

This flake exports:

- `devenvModule`: a module that enables all integrated generators (gitignore,
  GitHub workflows, renovate, sops, …)
- `devenvModules.<name>`: opinionated profiles you can compose in a
  `devenv.shell` (nix, javascript, rust, …)
- `homeManagerModule` and `homeManagerModules.<name>`: Home Manager modules for
  tooling and shell config
- `flakeModule`: a flake-parts module that can expose `treefmt` and `pre-commit`
  from a chosen `devenv.shell`

## Quick Start (Devenv)

Add devlib to your flake and import one or more `devenv` profiles.

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devlib = {
      url = "github:shikanime-studio/devlib";
      inputs = {
        devenv.follows = "devenv";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];

      perSystem = _: {
        devenv.shells.default.imports = [
          inputs.devlib.devenvModules.git
          inputs.devlib.devenvModules.nix
          inputs.devlib.devenvModules.shell
        ];
      };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
}
```

- Start a shell: `nix develop`
- If using `direnv`, allow the environment: `direnv allow`

## Using Devenv Modules

### Profiles

Profiles are composable `devenv` modules exported under `devenvModules.<name>`.
Most profiles import a shared base that enables formatting, Git hooks, and
generators (gitignore, GitHub workflows, renovate, …).

Available profiles:

- `devenvModules.docker`
- `devenvModules.elixir`
- `devenvModules.git`
- `devenvModules.go`
- `devenvModules.javascript`
- `devenvModules.nix`
- `devenvModules.ocaml`
- `devenvModules.opentofu`
- `devenvModules.python`
- `devenvModules.rust`
- `devenvModules.shell`
- `devenvModules.texlive`
- `devenvModules.yaml`

There are also preconfigured shells:

- `devenvModules.shikanime`
- `devenvModules.shikanime-studio`

### Enabling Generators

Enable module features under your shell configuration. Example enabling GitHub
workflow generation:

```nix
{
  devenv.shells.default = {
    imports = [ inputs.devlib.devenvModules.nix ];

    github = {
      enable = true;
      workflows = {
        commands.enable = true;
        cleanup.enable = true;
        integration.enable = true;
        triage.enable = true;
        update.enable = true;
        release.enable = true;
      };
    };
  };
}
```

When `github.enable = true`, devlib exposes a task that writes generated YAML
files to `.github/workflows`:

```bash
devenv tasks run devlib:github:workflows:install
```

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

      perSystem = _: {
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

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
}
```

## Home Manager

Use Home Manager modules from `homeManagerModules.<name>`.

```nix
{
  imports = [
    inputs.devlib.homeManagerModules.default
    inputs.devlib.homeManagerModules.vcs
    inputs.devlib.homeManagerModules.nix
  ];
}
```

## Templates

- Initialize a project:
  `nix flake init -t github:shikanime-studio/devlib#default`
- Use a minimal remote direnv setup:
  `nix flake init -t github:shikanime-studio/devlib#remote`
