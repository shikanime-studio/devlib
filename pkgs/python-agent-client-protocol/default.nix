{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonPackage rec {
  pname = "agent-client-protocol";
  version = "0.6.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
  };

  # No additional build inputs or dependencies needed for this simple package
  # if it only contains Python code and doesn't have native extensions.

  meta = with lib; {
    description = "Python client for the Agent Client Protocol (ACP)";
    homepage = "https://github.com/zed-industries/agent-client-protocol"; # Assuming this is the correct homepage
    license = licenses.asl20; # Assuming Apache-2.0 based on mistral-vibe's license
    platforms = platforms.unix;
  };
}
