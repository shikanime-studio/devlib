{ pkgs, ... }:

pkgs.buildGoModule rec {
  pname = "longhornctl";
  version = "1.10.1";

  src = pkgs.fetchFromGitHub {
    owner = "longhornctl";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-39WpihpqcvPDrQVqw9dx9djqaQd5WzO8+9YRbewn0AU=";
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
