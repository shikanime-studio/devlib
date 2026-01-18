{
  config,
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.deno
    pkgs.typescript-language-server
    pkgs.nodejs
    pkgs.vscode-langservers-extracted
  ];

  home.sessionVariables = {
    NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
    NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm";
  };

  programs.nushell.extraConfig = ''
    source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/node.nu
    source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/npm.nu
  '';

}
