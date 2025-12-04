{
  imports = [
    ./integrations/air.nix
    ./integrations/automata.nix
    ./integrations/buf.nix
    ./integrations/golangci-lint.nix
    ./integrations/docker.nix
    ./integrations/git-hooks.nix
    ./integrations/github.nix
    ./integrations/gitignore.nix
    ./integrations/sops.nix
    ./languages/elixir.nix
    ./languages/go.nix
    ./languages/javascript.nix
    ./languages/latex.nix
    ./languages/nix.nix
    ./languages/opentofu.nix
    ./languages/python.nix
    ./languages/rust.nix
    ./languages/shell.nix
  ];

  treefmt.config.settings.global.excludes = [
    "*.assetsignore"
    "*.dockerignore"
    "*.gcloudignore"
    "*.gif"
    "*.ico"
    "*.jpg"
    "*.png"
    "*.svg"
    "*.txt"
    "*.webp"
  ];
}
