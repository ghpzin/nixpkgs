{
  lib,
  libxkbcommon,
  wxGTK32,
  nix-update-script,
  testers,
  stdenvNoCC,
  autoPatchelfHook,
  fetchurl,
  dpkg,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "espanso";
  version = "2.3.0";
  dontBuild = true;
  dontStrip = true;
  src = fetchurl {
    url = "https://github.com/espanso/espanso/releases/download/v${finalAttrs.version}/espanso-debian-x11-amd64.deb";
    hash = "sha256-D3PqwJ8QaZgqrtAEFEKihkWsPgu9Wg8ktN/tMYfDxH0=";
  };
  installPhase = ''
    mkdir -p $out/bin
    cp ./usr/bin/espanso $out/bin/
  '';

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    wxGTK32
    libxkbcommon
  ];

  doCheck = false;

  passthru = {
    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Cross-platform Text Expander written in Rust";
    mainProgram = "espanso";
    homepage = "https://espanso.org";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      kimat
      n8henrie
    ];
    platforms = platforms.unix;
    longDescription = ''
      Espanso detects when you type a keyword and replaces it while you're typing.
    '';
  };
})
