{
  imports = [
    ./base.nix
  ];

  gitignore.templates = [
    "tt:erlang"
    "tt:elixir"
  ];

  languages.elixir.enable = true;

  treefmt.config.programs = {
    efmt.enable = true;
    mix-format.enable = true;
  };
}
