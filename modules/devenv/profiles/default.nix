{ lib, ... }:

with lib;

{
  imports = [ ./base.nix ] ++ filesystem.listFilesRecursive ../integrations;
}
