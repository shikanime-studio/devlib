{ pkgs, ... }:

pkgs.buildGoModule rec {
  pname = "longhornctl";
  version = "1.10.1";

  src = pkgs.fetchFromGitHub {
    owner = "longhornctl";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-ETbUOnR+beIDL8T3JR9kzmzp+WejmslooqyLwIPX1rI=";
  };

  ldflags = [
    "-s"
    "-w"
    "-X github.com/longhorn/cli/meta.Version=v${version}"
    "-X github.com/longhorn/cli/meta.GitCommit=${src.rev}"
    "-X github.com/longhorn/cli/meta.BuildDate=1970-01-01T00:00:00+00:00"
  ];

  passthru.update = ./update.nu;

  postInstall = ''
    mv $out/bin/local $out/bin/longhornctl-local
    mv $out/bin/remote $out/bin/longhornctl
  '';

  subPackages = [
    "cmd/local"
    "cmd/remote"
  ];

  vendorHash = null;

  meta = with pkgs.lib; {
    description = "Longhorn command line tool";
    homepage = "https://github.com/longhorn/cli";
    license = licenses.asl20;
    maintainers = with maintainers; [ shikanime ];
    mainProgram = "longhornctl";
  };
}
