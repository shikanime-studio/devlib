{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonPackage rec {
  pname = "pydantic";
  version = "2.12.4";

  src = fetchPypi {
    inherit pname version;
    hash = "1b45xbl86nb88nwd72bmna24jk16cqjzsszn2yvbb900a1avk30g";
  };

  # No additional build inputs or dependencies needed for this simple package
  # if it only contains Python code and doesn't have native extensions.

  meta = with lib; {
    description = "Data validation and settings management using Python type hints";
    homepage = "https://github.com/pydantic/pydantic";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
