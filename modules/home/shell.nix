{
  config,
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.bash-language-server
    pkgs.clang-tools
  ];

  programs.bash.historyFile = "${config.xdg.dataHome}/bash/history";

  programs.zsh.historyFile = "${config.xdg.dataHome}/zsh/history";
}
