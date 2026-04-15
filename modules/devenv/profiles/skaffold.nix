{
  config,
  pkgs,
  ...
}:

{
  imports = [ ./base.nix ];

  github.workflows.skaffold.enable = true;

  packages = [ pkgs.skaffold ];

  env.SKAFFOLD_CACHE_FILE = config.env.DEVENV_STATE + "/skaffold/cache";
  env.SKAFFOLD_REMOTE_CACHE_DIR = config.env.DEVENV_STATE + "/skaffold/remote-cache";
}
