{
  imports = [
    ./base.nix
  ];
  gitignore.templates = [
    "tt:python"
  ];

  languages.python = {
    enable = true;
    uv = {
      enable = true;
      sync.enable = true;
    };
  };

  treefmt.config.programs = {
    ruff-check.enable = true;
    ruff-format.enable = true;
  };
}
