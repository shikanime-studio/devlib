{
  config,
  pkgs,
  ...
}:

let
  cacheDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "${config.home.homeDirectory}/Library/Caches/npm"
    else
      "${config.xdg.cacheHome}/npm";
  configDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "${config.home.homeDirectory}/Library/Application Support/npm"
    else
      "${config.xdg.configHome}/npm";
in
{
  home.packages = [
    pkgs.deno
    pkgs.typescript-language-server
    pkgs.nodejs
    pkgs.vscode-langservers-extracted
  ];

  home.sessionVariables = {
    NPM_CONFIG_CACHE = cacheDir;
    NPM_CONFIG_USERCONFIG = configDir;
  };

  programs.nushell.extraConfig = ''
    source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/node.nu
    source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/npm.nu
  '';

}
