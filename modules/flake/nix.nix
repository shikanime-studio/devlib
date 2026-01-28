_: _: {
  perSystem = _: {
    pre-commit.settings.hooks.flake-checker.enable = true;

    treefmt.programs = {
      deadnix.enable = true;
      nixfmt.enable = true;
      statix.enable = true;
    };
  };
}
