{ pkgs, ... }:

{
  imports = [ ./base.nix ];

  gitignore.templates = [ "tt:node" ];

  renovate.settings.npm.enabled = true;

  languages.javascript = {
    enable = true;
    corepack.enable = true;
    package = pkgs.nodejs;
    pnpm = {
      enable = true;
      install.enable = true;
    };
  };

  treefmt.config.settings.global.excludes = [ "node_modules/*" ];

  github.settings.workflows = {
    integration.jobs.javascript = {
      uses = "shikanime-studio/devlib/workflows/javascript.yaml@main";
      secrets.PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
      "with".app-id = "\${{ vars.OPERATOR_APP_ID }}";
    };

    release.jobs = {
      javascript = {
        uses = "shikanime-studio/devlib/workflows/javascript.yaml@main";
        secrets.PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
        "with".app-id = "\${{ vars.OPERATOR_APP_ID }}";
      };

      release-branch.needs = [ "javascript" ];
      release-tag.needs = [ "javascript" ];
    };
  };
}
