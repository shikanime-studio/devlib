{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "mistralai";
  version = "1.9.11";

  src = fetchPypi {
    inherit pname version;
    hash = "12lvkksxlsmi2qz7g4v6z0ayp8yffgp2bpvqkv3nwx8sqc1y9y9x";
  };

  # No additional build inputs or dependencies needed for this simple package
  # if it only contains Python code and doesn't have native extensions.

  meta = with lib; {
    description = "The Mistral AI Python client";
    homepage = "https://github.com/mistralai/mistral-client-python";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
