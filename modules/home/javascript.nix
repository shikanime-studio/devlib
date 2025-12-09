{
  config,
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.typescript-language-server
    pkgs.vscode-langservers-extracted
    pkgs.nodejs
  ];

  home.sessionVariables = {
    NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
    NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm";
  };
}
