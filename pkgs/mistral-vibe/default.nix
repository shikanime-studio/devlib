{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "mistral-vibe";
  version = "1.1.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mistralai";
    repo = "mistral-vibe";
    rev = "v${version}";
    sha256 = "1y0lah0f89pmy8vw1vsswyn4qibasixakn3rb5bdzzdslx75xmcv";
  };

  build-system = with python3Packages; [
    uv-build
  ];

  dependencies = with python3Packages; [
    aiofiles
    httpx
    mcp
    (callPackage ../python-mistralai { })
    pexpect
    (callPackage ../python-pydantic { })
    pyperclip
    python-dotenv
    rich
    textual
    tomli-w
    (callPackage ../python-watchfiles { })
  ];

  pythonRelaxDeps = [
    "pydantic"
    "pydantic-settings"
    "watchfiles"
  ];

  pythonImportsCheck = [ "vibe" ];

  meta = with lib; {
    description = "Mistral Vibe client/tools";
    homepage = "https://github.com/mistralai/vibe";
    license = licenses.asl20;
    platforms = platforms.unix;
    mainProgram = "vibe";
  };
}
