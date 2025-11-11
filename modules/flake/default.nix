{
  perSystem =
    { config, ... }:
    {
      devenv.modules = [ ../devenv/default.nix ];
      pre-commit.settings = config.devenv.shells.default.git-hooks;
      treefmt = config.devenv.shells.default.treefmt.config;
    };
}
