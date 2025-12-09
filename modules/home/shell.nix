{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.bash;
in
{
  config = mkIf cfg.enable {
    home.packages = [
      pkgs.bash-language-server
      pkgs.clang-tools
    ];

    programs.bash.historyFile = "${config.xdg.dataHome}/bash/history";

    programs.zsh.historyFile = "${config.xdg.dataHome}/zsh/history";
  };
}
