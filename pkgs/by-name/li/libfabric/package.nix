{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  pkg-config,
  autoreconfHook,
  enablePsm2 ? (stdenv.hostPlatform.isx86_64 && stdenv.hostPlatform.isLinux),
  libpsm2,
  enableOpx ? (stdenv.hostPlatform.isx86_64 && stdenv.hostPlatform.isLinux),
  libuuid,
  numactl,
}:

stdenv.mkDerivation rec {
  pname = "libfabric";
  version = "2.3.0";

  enableParallelBuilding = true;

  src = fetchFromGitHub {
    owner = "ofiwg";
    repo = "libfabric";
    rev = "v${version}";
    sha256 = "sha256-pxSv6mg51It4+P1nAgXdWizTGpI31rn5+n3f4vD6ooY=";
  };

  patches = [
    # Fix build with gcc15
    # https://github.com/ofiwg/libfabric/pull/11417
    (fetchpatch {
      name = "libfabric-fix-opx_debug_ep_list_free-declaration-gcc15.patch";
      url = "https://github.com/ofiwg/libfabric/commit/a7d5798788a81e8a80f44b823b61e400bcb17f3e.patch";
      hash = "sha256-W8uSEPOO/7uMOf6EQNy5JsAOh9oeTbw+bNayryHj8HA=";
    })
  ];

  outputs = [
    "out"
    "dev"
    "man"
  ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs =
    lib.optionals enableOpx [
      libuuid
      numactl
    ]
    ++ lib.optionals enablePsm2 [ libpsm2 ];

  configureFlags = [
    (if enablePsm2 then "--enable-psm2=${libpsm2}" else "--disable-psm2")
    (if enableOpx then "--enable-opx" else "--disable-opx")
  ];

  meta = with lib; {
    homepage = "https://ofiwg.github.io/libfabric/";
    description = "Open Fabric Interfaces";
    license = with licenses; [
      gpl2
      bsd2
    ];
    platforms = platforms.all;
    maintainers = [ maintainers.bzizou ];
  };
}
