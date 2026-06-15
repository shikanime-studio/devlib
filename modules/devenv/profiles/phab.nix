{ pkgs, lib, ... }:

with lib;

let
  # Commit-msg hook: validates Summary: and Test Plan: sections
  phabCommitMsgHook = pkgs.writeShellScriptBin "phab-commit-msg-hook" (builtins.readFile ./phab-commit-msg-hook.sh);

  # Commitizen + cz-customizable installed via npm at shell-enter
  # We use a local prefix so it doesn't pollute the global npm namespace
  czEnv = pkgs.writeShellScriptBin "cz-commit" ''
    export NPM_CONFIG_PREFIX="''${DEVENV_ROOT:-$(pwd)}/.npm-global"
    export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"

    # Install on first use
    if [ ! -f "$NPM_CONFIG_PREFIX/bin/cz" ]; then
      mkdir -p "$NPM_CONFIG_PREFIX"
      npm install --prefix "$NPM_CONFIG_PREFIX" commitizen@4.3.2 cz-customizable@7.5.4 2>&1
    fi

    exec cz --config "${./phab-cz-config.js}" "$@"
  '';

in
{
  imports = [ ./base.nix ];

  packages = [
    pkgs.nodejs_22
    czEnv
    phabCommitMsgHook
  ];

  git-hooks.hooks.phab-commit-msg = {
    enable = true;
    name = "phab-commit-msg";
    entry = "${phabCommitMsgHook}/bin/phab-commit-msg-hook";
    stages = [ "commit-msg" ];
  };
}
