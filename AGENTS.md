# devlib

A collection of Nix flake modules that bootstrap a consistent, reproducible developer experience using `devenv`, `git-hooks`, and `treefmt`.

**Language:** Nix

## Structure

- `flake.nix` — Main flake exposing all modules
- `modules/` — Nix module definitions (devenv profiles, home-manager modules)
- `README.md` — Documentation and quick start guide

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

*Licensed under Apache-2.0. Test modules with `nix flake check` before submitting. Maintain backward compatibility with existing consumer flakes*