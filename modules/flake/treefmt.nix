{ withSystem, ... }:
_:

{
  perSystem =
    { system, ... }:
    {
      devenv.modules = [
        {
          treefmt.config.programs.prettier = withSystem system (
            { config, pkgs, ... }:
            {
              includes = [ "*.astro" ];
              package = pkgs.prettier.override {
                plugins = [
                  config.packages.prettier-plugin-astro
                  config.packages.prettier-plugin-tailwindcss
                ];
              };
              settings.overrides = [
                {
                  files = "*.astro";
                  options.parser = "astro";
                }
              ];
            }
          );

        }
      ];
    };
}
