{ pkgs, ... }:

{
  home.packages = [
    pkgs.basedpyright
    pkgs.jupyter-all
    pkgs.ruff
    pkgs.uv
  ];

  programs.nushell.extraConfig = ''
    source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/python.nu
    source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/pdm/pdm-completions.nu
    source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/poetry/poetry-completions.nu
    source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/pytest/pytest-completions.nu
  '';
}
