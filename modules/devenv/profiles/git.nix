{ config, pkgs, ... }:

let
  settingsFormat = pkgs.formats.toml { };

  configFile = settingsFormat.generate ".gitlint" {
    general.contrib = "contrib-body-requires-signed-off-by";
  };
in
{
  imports = [
    ./base.nix
  ];

  git-hooks.hooks.gitlint = {
    enable = true;
    entry = "${config.git-hooks.hooks.gitlint.package}/bin/gitlint --staged --msg-filename --config ${configFile}";
  };
}
