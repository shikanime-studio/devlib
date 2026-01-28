{
  imports = [
    ./default.nix
  ];

  gitignore = {
    enable = true;
    content = [
      ".pre-commit-config.yaml"
    ];
  };

  treefmt.enable = true;
}
