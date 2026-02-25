{
  config,
  pkgs,
  ...
}:

{
  home = {
    packages = [
      pkgs.gopls
    ];

    sessionPath = [
      "${config.xdg.dataHome}/go/bin"
    ];
  };

  programs = {
    go = {
      enable = true;
      env.GOPATH = "${config.xdg.dataHome}/go";
      telemetry.mode = "off";
    };

    gcc.enable = true;

    nushell.extraConfig = ''
      source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/godoc/godoc-completions.nu
    '';
  };
}
