{
  config,
  pkgs,
  ...
}:

let
  configDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "${config.home.homeDirectory}/Library/Application Support"
    else
      config.xdg.configHome;
in
{
  home = {
    packages = [ pkgs.rustup ];

    sessionPath = [
      "${configDir}/cargo/bin"
    ];

    sessionVariables = {
      CARGO_HOME = "${configDir}/cargo";
      RUSTUP_HOME = "${configDir}/rustup";
    };
  };

  programs.nushell.extraConfig = ''
    source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/cargo/cargo-completions.nu
  '';
}
