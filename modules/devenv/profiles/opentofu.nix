{
  imports = [
    ./base.nix
  ];

  gitignore.templates = [
    "ghc:OpenTofu"
  ];

  languages.opentofu.enable = true;
}
