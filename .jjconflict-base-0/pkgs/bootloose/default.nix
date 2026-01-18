{ pkgs, ... }:

pkgs.buildGoModule rec {
  pname = "bootloose";
  version = "0.9.1";

  src = pkgs.fetchFromGitHub {
    owner = "k0sproject";
    repo = "bootloose";
    rev = "v${version}";
    hash = "sha256-nTMT0PU2cn5yUEAEoKTDbenIrbBriT2E8kK2iwD/S6o=";
  };

  passthru.update = ./update.nu;

  vendorHash = "sha256-1unOXFR8AvvkdkNleXYpR0WsZthoLmuIDPKB/M1GfPw=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/k0sproject/bootloose/version.Environment=production"
    "-X github.com/carlmjohnson/versioninfo.Version=v${version}"
    "-X github.com/carlmjohnson/versioninfo.Revision=v${version}"
  ];

  tags = [
    "netgo"
    "osusergo"
    "static_build"
  ];

  checkFlags = [
    # Requires Docker
    "-skip=TestEndToEnd"
  ];

  meta = with pkgs.lib; {
    description = "Manage containers that look like virtual machines";
    homepage = "https://github.com/k0sproject/bootloose";
    license = licenses.asl20;
    maintainers = with maintainers; [ shikanime ];
    mainProgram = "bootloose";
  };
}
