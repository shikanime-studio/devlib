{
  imports = [ ./base.nix ];

  git-hooks.hooks.hadolint.enable = true;

  renovate.settings.dockerfile.enabled = true;

  treefmt.config.programs.dockerfmt.enable = true;
}
