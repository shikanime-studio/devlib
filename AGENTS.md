# Devlib

A collection of Nix flake modules that bootstrap a consistent, reproducible
developer experience using `devenv`, `git-hooks`, and `treefmt`.

**Language:** Nix

## Structure

- `flake.nix` — Main flake exposing all modules
- `modules/` — Nix module definitions (devenv profiles, home-manager modules)
- `README.md` — Documentation and quick start guide

## Module Types

- **devenv profiles** — Pre-configured development environments
- **home-manager modules** — Reusable Home Manager configurations

## Commit Style

- Plain-text capitalized title, no conventional-commit prefix
- Body with labels: `Design:`, `Related:`, `Closes #`
- Keep Markdown lines wrapped at 80 columns and run `nix fmt` before shipping

## Stack

- 1 commit == 1 PR via ghstack (1 commit is 1 logical atomic change)
- Split work into stacked PRs to keep each PR small and reviewable
- To pull down an existing stack: `ghstack checkout <PR_NUMBER>`
- To update a PR: edit files, then `jj squash` (or `git commit --amend`) into the
  **target commit** of the stack — the one that PR represents
- Resubmit with `ghstack` after squashing
- `ghstack land` on the head PR to land the entire stack
- Never `gh pr merge` (creates poisoned commits)
- Never force-push ghstack branches

## Protect `main`

- Require 1 approving review
- Require linear history (no merge commits)
- Require signed commits
- Squash+rebase merge only

*Licensed under Apache-2.0. Test modules with `nix flake check` before
submitting. Maintain backward compatibility with existing consumer flakes.
Always use worktrees when making changes.*
