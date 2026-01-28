_: _: {
  perSystem =
    { config, pkgs, ... }:
    {
      pre-commit.settings.hooks.eslint.enable = true;

      treefmt = {
        programs.prettier = {
          enable = true;
          includes = [
            "*.astro"
            "*.cjs"
            "*.css"
            "*.html"
            "*.js"
            "*.jsx"
            "*.mdx"
            "*.mjs"
            "*.mts"
            "*.scss"
            "*.ts"
            "*.tsx"
            "*.vue"
          ];
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
        };
        settings.global.excludes = [ "node_modules/*" ];
      };
    };
}
