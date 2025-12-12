{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonPackage rec {
  pname = "watchfiles";
  version = "1.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "1wmk6451qjih843yv3xbhflpx7s09i9qmx7ckjqhmx642rfcnwx1";
  };

  # No additional build inputs or dependencies needed for this simple package
  # if it only contains Python code and doesn't have native extensions.

  meta = with lib; {
    description = "File watching and code reload in Python.";
    homepage = "https://github.com/samuelcolvin/watchfiles";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
