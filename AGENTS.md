# Devlib

A collection of Nix flake modules that bootstrap a consistent, reproducible developer experience using `devenv`, `git-hooks`, and `treefmt`.

**Language:** Nix

## Structure

- `flake.nix` — Main flake exposing all modules
- `modules/` — Nix module definitions (devenv profiles, home-manager modules)
- `README.md` — Documentation and quick start guide

## Commit Style

- Capitalized title, imperative mood, no trailing punctuation, ≤72 chars
- Body sections (in order):
  - `Summary:` — what the change does
  - `Test Plan:` — how you verified it
  - `Reviewers:` — @mentions (optional)
  - `Subscribers:` — @mentions (optional)
- Use `cz commit` for interactive commit (commitizen)
- Keep lines wrapped at 80 columns and run `nix fmt` before shipping

> Note: the section format follows conventions used by several large-scale
> code review systems. The `Summary` and `Test Plan` sections are required
> by the commit-msg hook; `Reviewers` and `Subscribers` are optional.

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