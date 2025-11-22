#!/usr/bin/env nix-shell
#!nix-shell -i nu -p nushell

let latest = (
  http get https://api.github.com/repos/longhorn/cli/releases/latest
  | get tag_name
)

let prefetch = (
  ^nix-prefetch-url --unpack $"https://github.com/longhorn/cli/archive/refs/tags/($latest).tar.gz"
  | str trim
)

let sri = (
  ^nix hash convert --hash-algo sha256 --to sri $prefetch
  | str trim
)

open ./default.nix
| str replace -r 'version = "[^"]*"' $"version = \"($latest | str trim -l -c 'v')\""
| str replace -r 'hash = "[^"]*"' $"hash = \"($sri)\""
| save -f ./default.nix
