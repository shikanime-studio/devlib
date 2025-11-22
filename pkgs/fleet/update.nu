#!/usr/bin/env nix
#! nix shell nixpkgs#nushell --command nu

let latest = (
  http get https://api.github.com/repos/rancher/fleet/releases/latest
  | get tag_name
)

let prefetch = (
  ^nix-prefetch-url --unpack $"https://github.com/rancher/fleet/archive/refs/tags/($latest).tar.gz"
  | str trim
)

let sri = (
  ^nix hash convert --hash-algo sha256 --to sri $prefetch
  | str trim
)

open $"($env.FILE_PWD)/default.nix"
| str replace -r 'version = "[^"]*"' $"version = \"($latest | str trim -l -c 'v')\""
| str replace -r 'hash = "[^"]*"' $"hash = \"($sri)\""
| save -f $"($env.FILE_PWD)/default.nix"
