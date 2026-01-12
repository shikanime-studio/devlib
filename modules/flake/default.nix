_:
{ inputs, ... }:

{
  perSystem =
    { config, lib, ... }:
    with lib;
    let
      cfg = config.devlib;
    in
    {
      options.devlib = {
        devenv = {
          enable = mkOption {
            type = types.bool;
            default = inputs.devenv != null;
            description = "Enable devenv.";
          };
        };

        treefmt = {
          enable = mkOption {
            type = types.bool;
            default = inputs.treefmt-nix != null;
            description = "Enable treefmt.";
          };
        };
      };

      config = {
        devenv.modules = mkIf cfg.devenv.enable [
          ../devenv/profiles/default.nix
          {
            treefmt = mkIf cfg.treefmt.enable {
              enable = true;
              config =
                let
                  # Filter out internal/computed options from programs to avoid conflicts/errors.
                  treefmtPrograms = lib.mapAttrs (
                    _: v: builtins.removeAttrs v [ "finalPackage" ]
                  ) config.treefmt.programs;

                  # Keep global settings but remove generated formatter config.
                  treefmtSettings = builtins.removeAttrs config.treefmt.settings [ "formatter" ];
                in
                {
                  programs = treefmtPrograms;
                  settings = treefmtSettings;
                };
            };
          }
        ];
      };
    };
}
