{ pkgs, ... }:

let
  yamlFormat = pkgs.formats.yaml { };

  configFile = yamlFormat.generate ".gitlint" {
    general.contrib = "contrib-body-requires-signed-off-by";
  };

  gitlint =
    pkgs.runCommand "gitlint-wrapped"
      {
        buildInputs = [ pkgs.makeWrapper ];
        meta.mainProgram = "gitlint";
      }
      ''
        makeWrapper ${pkgs.gitlint}/bin/gitlint $out/bin/gitlint \
          --add-flags "--config ${configFile}"
      '';

in
{
  imports = [
    ./base.nix
  ];

  git-hooks.hooks.gitlint = {
    enable = true;
    package = gitlint;
  };
}
