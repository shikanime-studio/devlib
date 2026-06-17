# Project

This project is bootstrapped from
[shikanime-studio/devlib](https://github.com/shikanime-studio/devlib) using the
`default` template. It uses Nix flakes with devenv for a reproducible developer
environment.

**Language:** Nix (plus any project-specific languages)

## Environment

- Enter the dev shell with `direnv allow` (or `nix develop`)
- The flake provides devenv shells with pre-configured tooling
- Cachix substituters are pre-configured for faster builds

## Structure

- `flake.nix` — Project flake (imports devlib modules)
- `.envrc` — direnv entry point
- `devenv.nix` or `devenv/` — devenv configuration (if present)

## Commit Style

- Plain-text capitalized title, no conventional-commit prefix
- Body with labels: `Design:`, `Related:`, `Closes #`
- Keep Markdown lines wrapped at 80 columns and run `nix fmt` before shipping

## Stack

- 1 commit == 1 PR via ghstack
- Amend + `ghstack` to resubmit
- `ghstack land` on head PR to land the entire stack
- Never `gh pr merge` (creates poisoned commits)
- Never force-push ghstack branches
- ghstack only works on HEAD commit chains, not detached HEADs

## Protect `main`

- Require 1 approving review
- Require linear history (no merge commits)
- Require signed commits
- Squash+rebase merge only

_Licensed under Apache-2.0. Run `nix flake check` before submitting. Keep
backward compatibility with existing consumer flakes._
