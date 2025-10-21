{ flake-parts-lib, ... }:

{
  imports = [
    ./nix.nix
  ];

  options.perSystem = flake-parts-lib.mkPerSystemOption (_: {
    treefmt = {
      enableDefaultExcludes = true;
      projectRootFile = "flake.nix";
      programs = {
        prettier.enable = true;
        shfmt.enable = true;
      };
      settings.global.excludes = [
        "LICENSE"
      ];
    };
  });
}
