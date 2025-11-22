{ pkgs, ... }:

pkgs.buildGoModule rec {
  pname = "longhornctl";
  version = "0.14.0";

  src = pkgs.fetchFromGitHub {
    owner = "longhornctl";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-D6kFOY8jCjsFHftjdhocDGAowGTy5IwVxfZdiFY4QvI=";
  };

  ldflags = [
    "-s"
    "-w"
    "-X github.com/longhornctl/cli/meta.Version=v${version}"
    "-X github.com/longhornctl/cli/meta.GitCommit=${src.rev}"
    "-X github.com/longhornctl/cli/meta.BuildDate=1970-01-01T00:00:00+00:00"
  ];

  passthru.update = ./update.nu;

  postInstall = ''
    mv $out/bin/remote $out/bin/longhornctl
  '';

  subPackages = [ "cmd/remote" ];

  vendorHash = null;

  meta = with pkgs.lib; {
    description = "Longhorn command line tool";
    homepage = "https://github.com/longhornctl/cli";
    license = licenses.asl20;
    maintainers = with maintainers; [ shikanime ];
    mainProgram = "longhornctl";
  };
}
