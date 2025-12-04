{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.languages.elixir;
in
{
  config = mkIf cfg.enable {
    gitignore.templates = [
      "tt:erlang"
      "tt:elixir"
    ];

    treefmt.config.programs = {
      efmt.enable = mkDefault true;
      mix-format.enable = mkDefault true;
    };
  };
}
