{
  config,
  pkgs,
  ...
}:

let
  cargoConfigDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "${config.home.homeDirectory}/Library/Application Support/cargo"
    else
      "${config.xdg.configHome}/cargo";

  rustupConfigDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "${config.home.homeDirectory}/Library/Application Support/rustup"
    else
      "${config.xdg.configHome}/rustup";
in
{
  home = {
    packages = [ pkgs.rustup ];

    sessionPath = [
      "${cargoConfigDir}/bin"
    ];

    sessionVariables = {
      CARGO_HOME = cargoConfigDir;
      RUSTUP_HOME = rustupConfigDir;
    };
  };

  programs.nushell.extraConfig = ''
    source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/cargo/cargo-completions.nu
  '';
}
