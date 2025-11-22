{ pkgs, ... }:

pkgs.buildGoModule rec {
  pname = "fleet";
  version = "0.14.0";

  src = pkgs.fetchFromGitHub {
    owner = "rancher";
    repo = "fleet";
    rev = "v${version}";
    hash = "sha256-D6kFOY8jCjsFHftjdhocDGAowGTy5IwVxfZdiFY4QvI=";
  };

  passthru.update = ./update.nu;

  postInstall = ''
    mv $out/bin/fleetagent $out/bin/fleet-agent
    mv $out/bin/fleetcli $out/bin/fleet
    mv $out/bin/fleetcontroller $out/bin/fleet-controller
  '';

  subPackages = [
    "cmd/fleetagent"
    "cmd/fleetcli"
    "cmd/fleetcontroller"
  ];

  vendorHash = "sha256-iDy266is92puTHkCkkSh9gFXN9UdwYq+buVhFLTl+Y0=";

  meta = with pkgs.lib; {
    description = "Fleet command line tool";
    homepage = "https://github.com/rancher/fleet";
    license = licenses.asl20;
    maintainers = with maintainers; [ shikanime ];
    mainProgram = "fleet";
  };
}
