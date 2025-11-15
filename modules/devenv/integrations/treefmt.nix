{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.treefmt;

  treeRoot = if config.git.root != null then config.git.root else config.devenv.root;

  treefmtWrapper =
    let
      treeRootOption =
        if cfg.config.projectRootFile != "" then
          "--tree-root-file " + lib.escapeShellArg cfg.config.projectRootFile
        else
          "--tree-root " + lib.escapeShellArg treeRoot;
    in
    pkgs.writeShellScriptBin "treefmt" ''
      exec ${cfg.config.package}/bin/treefmt --config-file ${cfg.config.build.configFile} "$@" ${treeRootOption}
    '';
in
{
  config = mkIf cfg.enable {
    tasks."devenv:treefmt:run".exec = "${treefmtWrapper}/bin/treefmt";
  };
}
