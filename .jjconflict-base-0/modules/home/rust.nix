{
  config,
  pkgs,
  ...
}:

{
  home = {
    packages = [ pkgs.rustup ];

    sessionPath = [
      "${config.xdg.configHome}/cargo/bin"
    ];

    sessionVariables = {
      CARGO_HOME = "${config.xdg.configHome}/cargo";
      RUSTUP_HOME = "${config.xdg.configHome}/rustup";
    };
  };

  programs.nushell.extraConfig = ''
    source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/cargo/cargo-completions.nu
  '';
}
