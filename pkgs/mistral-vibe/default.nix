{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  uv-build,
  aiofiles,
  httpx,
  mcp,
  mistralai,
  pexpect,
  pydantic,
  pydantic-settings,
  pyperclip,
  python-dotenv,
  rich,
  textual,
  tomli-w,
  watchfiles,
}:

buildPythonApplication rec {
  pname = "mistral-vibe";
  version = "1.1.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mistralai";
    repo = "mistral-vibe";
    rev = "v${version}";
    sha256 = "1y0lah0f89pmy8vw1vsswyn4qibasixakn3rb5bdzzdslx75xmcv";
  };

  build-system = [
    uv-build
  ];

  dependencies = [
    aiofiles
    httpx
    mcp
    mistralai
    pexpect
    pydantic
    pydantic-settings
    pyperclip
    python-dotenv
    rich
    textual
    tomli-w
    watchfiles
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
