{
  imports = [ ./default.nix ];

  git-hooks.hooks.trufflehog.enable = true;

  gitignore = {
    enable = true;
    content = [ ".pre-commit-config.yaml" ];
  };

  treefmt = {
    enable = true;
    config = {
      programs = {
        autocorrect.enable = true;
        oxfmt.enable = true;
        rumdl-check.enable = true;
        xmllint.enable = true;
      };
      settings = {
        formatter.oxfmt.includes = [
          "*.cjs"
          "*.css"
          "*.graphql"
          "*.hbs"
          "*.html"
          "*.js"
          "*.json"
          "*.json5"
          "*.jsonc"
          "*.jsx"
          "*.md"
          "*.mdx"
          "*.mjs"
          "*.mustache"
          "*.scss"
          "*.toml"
          "*.ts"
          "*.tsx"
          "*.vue"
          "*.yaml"
          "*.yml"
        ];
        global.excludes = [
          ".devenv/*"
          ".direnv/*"
          "*.assetsignore"
          "*.dockerignore"
          "*.gcloudignore"
          "*.gif"
          "*.ico"
          "*.jpg"
          "*.png"
          "*.svg"
          "*.txt"
          "*.webp"
        ];
      };
    };
  };
}
