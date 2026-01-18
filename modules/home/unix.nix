{ pkgs, ... }:

{
  programs.nushell.extraConfig = ''
    use ${pkgs.nu_scripts}/share/nu_scripts/modules/argx *
    use ${pkgs.nu_scripts}/share/nu_scripts/modules/lg *
    use ${pkgs.nu_scripts}/share/nu_scripts/modules/system *

    source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/curl/curl-completions.nu
    source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/less/less-completions.nu
    source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/make/make-completions.nu
    source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/man/man-completions.nu
    source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/tar/tar-completions.nu
  '';
}
