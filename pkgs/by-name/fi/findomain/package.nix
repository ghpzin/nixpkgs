{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "findomain";
  version = "9.0.4-unstable-2025-04-20";

  src = fetchFromGitHub {
    owner = "findomain";
    repo = "findomain";
    rev = "1c246de8300ef6dee7096bad2d2a1a239549c7f0";
    hash = "sha256-59N0liGUFLMK5Z4KiDjGdKetO36Enj4XmEJaY91j8LU=";
  };

  cargoHash = "sha256-cyUOdsQkiWA0zJQu/yEKDG/kyLDULI5zcK5QQsY0ZFU=";

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  postInstall = ''
    installManPage findomain.1
  '';

  meta = {
    description = "Fastest and cross-platform subdomain enumerator";
    homepage = "https://github.com/Findomain/Findomain";
    changelog = "https://github.com/Findomain/Findomain/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      Br1ght0ne
      figsoda
    ];
    mainProgram = "findomain";
  };
}
