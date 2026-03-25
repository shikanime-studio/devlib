{
  imports = [ ./base.nix ];

  git-hooks.hooks.flake-checker.enable = true;

  gitignore.templates = [
    "repo:shikanime-studio/gitignore/refs/heads/main/Devenv.gitignore"
  ];

  languages.nix.enable = true;

  renovate.settings.nix.enabled = true;

  treefmt.config.programs = {
    deadnix.enable = true;
    nixfmt.enable = true;
    statix.enable = true;
  };

  github.settings.workflows = {
    integration.jobs.nix = {
      uses = "shikanime-studio/devlib/workflows/nix.yaml@main";
      secrets = {
        CACHIX_AUTH_TOKEN = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
        PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
      };
    };

    release.jobs = {
      nix = {
        uses = "shikanime-studio/devlib/workflows/nix.yaml@main";
        secrets = {
          CACHIX_AUTH_TOKEN = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
          PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
        };
      };

      release-branch.needs = [ "nix" ];
      release-tag.needs = [ "nix" ];
    };
  };
}
