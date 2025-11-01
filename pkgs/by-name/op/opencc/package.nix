{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  cmake,
  python3,
  opencc,
  rapidjson,
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opencc";
  version = "1.1.9";

  src = fetchFromGitHub {
    owner = "BYVoid";
    repo = "OpenCC";
    tag = "ver.${finalAttrs.version}";
    hash = "sha256-JBTegQs9ALp4LdKKYMNp9GYEgqR9O8IkX6LqatvaTic=";
  };

  patches = [
    # Fix build with gcc15
    # https://github.com/BYVoid/OpenCC/pull/934
    (fetchpatch {
      name = "opencc-SerializedValues-add-missing-include-cstdint.patch";
      url = "https://github.com/BYVoid/OpenCC/commit/72cae18cfe4272f2b11c9ec1c44d6af7907abcab.patch";
      hash = "sha256-Cd95AsW/tLk2l8skxqfEfQUm0t23G4ocoirauwMbuwk=";
    })
  ];

  nativeBuildInputs = [
    cmake
    python3
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    opencc # opencc_dict
  ];

  buildInputs = [
    rapidjson
  ];

  # TODO use more system dependencies
  cmakeFlags = [
    (lib.cmakeBool "USE_SYSTEM_RAPIDJSON" true)
  ];

  passthru = {
    updateScript = gitUpdater { rev-prefix = "ver."; };
  };

  meta = {
    homepage = "https://github.com/BYVoid/OpenCC";
    license = lib.licenses.asl20;
    description = "Project for conversion between Traditional and Simplified Chinese";
    longDescription = ''
      Open Chinese Convert (OpenCC) is an opensource project for conversion between
      Traditional Chinese and Simplified Chinese, supporting character-level conversion,
      phrase-level conversion, variant conversion and regional idioms among Mainland China,
      Taiwan and Hong kong.
    '';
    maintainers = with lib.maintainers; [ sifmelcara ];
    platforms = with lib.platforms; linux ++ darwin;
  };
})
