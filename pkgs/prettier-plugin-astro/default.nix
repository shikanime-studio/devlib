{
  fetchFromGitHub,
  fetchPnpmDeps,
  lib,
  nodejs,
  pnpm_9,
  pnpmConfigHook,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "prettier-plugin-astro";
  version = "0.14.1";

  src = fetchFromGitHub {
    owner = "withastro";
    repo = "prettier-plugin-astro";
    rev = "v${finalAttrs.version}";
    hash = "sha256-XGPz4D2UKOonet0tX3up5mCxw3/69XYPScxb9l7nzpE=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm_9
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = finalAttrs.pnpmDepsHash;
    pnpm = pnpm_9;
  };

  pnpmDepsHash = "sha256-vs7KOsX+jmnY2+RKJlhSWDVyTUxAO2af3lyao9AYFr8=";

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules/prettier-plugin-astro/dist
    cp -r dist/* $out/lib/node_modules/prettier-plugin-astro/dist
    cp -r node_modules $out/lib/node_modules/prettier-plugin-astro/node_modules
    runHook postInstall
  '';

  meta = with lib; {
    description = "Prettier plugin for Astro";
    homepage = "https://github.com/withastro/prettier-plugin-astro";
    license = licenses.mit;
    maintainers = with maintainers; [ shikanime ];
  };
})
