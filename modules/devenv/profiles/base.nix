{
  imports = [
    ../integrations/air.nix
    ../integrations/automata.nix
    ../integrations/buf.nix
    ../integrations/golangci-lint.nix
    ../integrations/git-hooks.nix
    ../integrations/github.nix
    ../integrations/gitignore.nix
    ../integrations/sops.nix
  ];

  gitignore.enable = true;

  treefmt.enable = true;
}
