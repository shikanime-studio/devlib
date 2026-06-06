{
  imports = [ ./base.nix ];

  integrations.gitnr.".gitignore".templates = [ "ghc:OpenTofu" ];

  languages.opentofu.enable = true;

  treefmt.config.programs = {
    hclfmt.enable = true;
    terraform.enable = true;
  };
}
