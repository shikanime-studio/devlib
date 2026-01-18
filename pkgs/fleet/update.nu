#!/usr/bin/env nix
#! nix shell nixpkgs#nushell --command nu

let latest = (
  http get https://api.github.com/repos/rancher/fleet/releases/latest
  | get tag_name
)

let prefetch = (
  ^nix flake prefetch github:rancher/fleet/($latest) --json
  | from json
  | get hash
)

open $"($env.FILE_PWD)/default.nix"
| str replace -r 'version = "[^"]*"' $"version = \"($latest | str trim -l -c 'v')\""
| str replace -r 'hash = "[^"]*"' $"hash = \"($prefetch)\""
| save -f $"($env.FILE_PWD)/default.nix"
