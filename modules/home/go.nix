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

  programs.go = {
    enable = true;
    env.GOPATH = "${config.xdg.dataHome}/go";
    telemetry.mode = "off";
  };
}
