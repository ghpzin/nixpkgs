{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  protobuf_33,
  zlib,
  buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "protobuf-c";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "protobuf-c";
    repo = "protobuf-c";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bpxk2o5rYLFkx532A3PYyhh2MwVH2Dqf3p/bnNpQV7s=";
  };

  # Fix buidl with gcc16
  # https://github.com/protobuf-c/protobuf-c/issues/776
  env.NIX_CFLAGS_COMPILE = "-std=gnu++20";

  outputs = [
    "out"
    "dev"
    "lib"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    protobuf_33
    zlib
  ];

  env.PROTOC = lib.getExe buildPackages.protobuf_33;

  meta = {
    homepage = "https://github.com/protobuf-c/protobuf-c/";
    description = "C bindings for Google's Protocol Buffers";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ nickcao ];
  };
})
