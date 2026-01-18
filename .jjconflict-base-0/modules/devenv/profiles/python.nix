{
  imports = [
    ./base.nix
  ];

  gitignore.templates = [
    "tt:python"
  ];

  renovate.settings.uv.enabled = true;

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
