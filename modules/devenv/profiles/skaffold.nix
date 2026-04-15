{
  config,
  pkgs,
  ...
}:

{
  imports = [ ./base.nix ];

  env = {
    SKAFFOLD_CACHE_FILE = config.env.DEVENV_STATE + "/skaffold/cache";
    SKAFFOLD_REMOTE_CACHE_DIR = config.env.DEVENV_STATE + "/skaffold/remote-cache";
  };

  github.workflows.skaffold.enable = true;

  packages = [ pkgs.skaffold ];
}
