_: _: {
  perSystem =
    _:
    {
      pre-commit.settings.hooks.flake-checker.enable = true;
      treefmt.config.programs = {
        deadnix.enable = true;
        nixfmt.enable = true;
        statix.enable = true;
      };
    };
}
