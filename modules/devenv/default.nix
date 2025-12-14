{ lib, ... }:

with lib;

{
  imports = filesystem.listFilesRecursive ./integrations;
}
