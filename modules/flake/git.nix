_: _: {
  perSystem =
    { pkgs, ... }:
    let
      gitlint =
        pkgs.runCommand "gitlint-wrapped"
          {
            buildInputs = [ pkgs.makeWrapper ];
            meta.mainProgram = "gitlint";
          }
          ''
            makeWrapper ${pkgs.gitlint}/bin/gitlint $out/bin/gitlint \
              --add-flags "--contrib CC1"
          '';
    in
    {
      pre-commit.settings.hooks.gitlint = {
        enable = true;
        package = gitlint;
      };
    };
}
