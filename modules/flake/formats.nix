_: _: {
  perSystem =
    { config, pkgs, ... }:
    {
      treefmt.config.programs = {
        actionlint.enable = true;
        buf.enable = true;
        prettier = {
          enable = true;
          includes = [
            "*.astro"
            "*.css"
            "*.html"
            "*.js"
            "*.json"
            "*.jsx"
            "*.md"
            "*.mdx"
            "*.scss"
            "*.ts"
            "*.tsx"
            "*.yaml"
            "*.yml"
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
        taplo.enable = true;
        xmllint.enable = true;
      };
    };
}
