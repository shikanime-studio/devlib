{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  openssl,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "mistral-vibe";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "mistralai";
    repo = "vibe";
    rev = "v${version}";
    sha256 = lib.fakeSha256;
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl
    zlib
  ];

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

  meta = with lib; {
    description = "Mistral Vibe client/tools";
    homepage = "https://github.com/mistralai/vibe";
    license = licenses.asl20;
    platforms = platforms.unix;
    mainProgram = "vibe";
  };
}
