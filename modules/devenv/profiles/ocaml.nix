{
  imports = [
    ./base.nix
  ];

  gitignore.templates = [ "tt:ocaml" ];

  languages.ocaml.enable = true;
}
