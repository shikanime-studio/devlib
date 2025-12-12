{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonPackage rec {
  pname = "pydantic-settings";
  version = "2.12.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
  };

  # No additional build inputs or dependencies needed for this simple package
  # if it only contains Python code and doesn't have native extensions.

  meta = with lib; {
    description = "Pydantic settings management";
    homepage = "https://github.com/pydantic/pydantic-settings";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
