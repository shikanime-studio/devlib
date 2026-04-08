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
- `flakeModule`: a flake-parts module that can expose `treefmt` and
  `pre-commit` from a chosen `devenv.shell`

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

- Initialize a project: `nix flake init -t github:shikanime-studio/devlib#default`
- Use a minimal remote direnv setup: `nix flake init -t github:shikanime-studio/devlib#remote`

## Testing Strategy

Devlib should adopt a hybrid testing model:

- use Home Manager style golden tests for `modules/home/*`
- use devenv style integration tests for `modules/devenv/*`, generator tasks and
  templates
- keep `nix flake check` as the repository-wide contract that every pull request
  must pass

### Goals

- Protect exported interfaces: `devenvModule`, `devenvModules.*`,
  `homeManagerModule`, `homeManagerModules.*`, `flakeModule` and templates.
- Catch regressions in generated files such as GitHub workflows, gitignore,
  renovate and license outputs.
- Verify composition across supported systems: `x86_64-linux`,
  `aarch64-linux`, and `aarch64-darwin`.
- Make every new module land with at least one focused regression test.

### Test Layers

#### 1. Evaluation and contract checks

Keep fast checks in `flake check` for pull requests:

- evaluate all exported modules and templates
- build the default template and remote template
- verify the flake module can project `treefmt` and `pre-commit` from a selected
  shell
- assert representative profile compositions such as `git + nix + shell` and
  `shikanime-studio`

This is the fastest feedback loop and should stay mandatory on every change.

#### 2. Home Manager golden tests

Follow the Home Manager pattern for `modules/home/*`:

- create `tests/home/<module>/default.nix` that lists the cases for one module
- keep each test case focused on one behavior, for example generated files,
  package installation or platform-specific paths
- compare generated files against checked-in expected outputs
- stub packages when package contents are irrelevant to the assertion
- gate Darwin-only or Linux-only assertions so evaluation stays portable

Good candidates in devlib:

- `modules/home/shell.nix`: shell aliases, environment variables and sourced
  files
- `modules/home/vcs.nix`: enabled CLI programs and package selection
- language modules such as `javascript.nix`, `python.nix`, and `rust.nix`:
  expected package sets and config file generation

#### 3. Devenv integration tests

Follow devenv's `tests/` and `examples/` model for `modules/devenv/*`:

- each test lives in its own directory with a `devenv.nix`
- add `.test.sh` when behavior must be asserted from inside the shell
- use `.test-config.yml` for platform allowlists or known broken systems
- keep examples executable so they double as documentation and regression tests

Good candidates in devlib:

- `github.enable = true` generates workflow files with the expected names and
  YAML structure
- `devenv tasks run devlib:github:workflows:install` writes files into
  `.github/workflows`
- profile imports enable the expected `treefmt`, `git-hooks`, and package sets
- the flake module correctly forwards `treefmt` and `pre-commit` from a chosen
  shell

#### 4. Template smoke tests

Each exported template should be instantiated in CI and checked for:

- successful `nix flake show`
- successful `nix flake check` when applicable
- successful shell entry for the default template
- expected generated files such as `.envrc` and `flake.nix`

Templates are part of the public API, so they should be treated like examples
with CI coverage.

### Recommended Layout

```text
tests/
  home/
    shell/
    vcs/
    javascript/
    python/
    rust/
  devenv/
    github-workflows/
    flake-module/
    profiles/
examples/
  default-template/
  remote-template/
```

### CI Plan

For pull requests:

- run `nix flake check` on the supported matrix already used by GitHub Actions
- run only the affected Home Manager golden tests
- run only the affected devenv integration tests
- always run template smoke tests

For scheduled or release validation:

- run the full Home Manager style suite
- run the full devenv integration suite
- exercise all supported systems

### Contribution Rule

Every behavior change should add or update a test in the nearest layer:

- `modules/home/*` change -> add or update a Home Manager golden test
- `modules/devenv/integrations/*` change -> add or update a devenv integration
  test
- `modules/flake/*` change -> add or update contract checks and at least one
  integration fixture
- template change -> add or update a template smoke test

This keeps devlib close to Home Manager's module discipline while using devenv's
real-world shell and workflow testing style for end-to-end coverage.
