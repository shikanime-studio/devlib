{
  imports = [
    ./base.nix
  ];

  gitignore.templates = [
    "tt:erlang"
    "tt:elixir"
  ];

  renovate.settings.mix.enabled = true;

  languages.elixir.enable = true;

  treefmt.config.programs = {
    efmt.enable = true;
    mix-format.enable = true;
  };
}
