{
  config,
  flake-parts-lib,
  lib,
  ...
}:

with lib;

{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    {
      config,
      pkgs,
      system,
      ...
    }:
    {
      options.devlib.nix = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable Nix";
        };
      };

      config = mkIf config.devlib.nix.enable {
        treefmt.programs = {
          nixfmt.enable = true;
          statix.enable = true;
        };
      };
    }
  );
}
