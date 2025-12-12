{
  lib,
  python3Packages,
  fetchPypi,
  rustPlatform,
}:

python3Packages.buildPythonPackage rec {
  pname = "textual-speedups";
  version = "0.2.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
  ];

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
  };

  meta = with lib; {
    description = "Optional Rust implementations of some Textual classes";
    homepage = "https://github.com/Textualize/textual-speedups";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
