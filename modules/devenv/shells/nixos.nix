{ pkgs, ... }:

{
  imports = [
    ./base.nix
  ];

  packages = [
    pkgs.nixpkgs-review
  ];
}
