{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  kernel,
}:

stdenv.mkDerivation rec {
  pname = "dddvb";
  version = "0.9.40";

  src = fetchFromGitHub {
    owner = "DigitalDevices";
    repo = "dddvb";
    tag = version;
    hash = "sha256-6FDvgmZ6KHydy5CfrI/nHhKAJeG1HQ/aRUojFDSEzQY=";
  };

  postPatch = ''
    sed -i '/depmod/d' Makefile
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-stringop-truncation" 
    "-Wno-unused-result"
    "-Wno-array-bounds"
    "-Wno-stringop-overflow"
    "-Wno-format-security"
  ];

  INSTALL_MOD_PATH = placeholder "out";

  enableParallelBuilding = true;

  meta = with lib; {
    homepage = "https://github.com/DigitalDevices/dddvb";
    description = "ddbridge linux driver";
    license = licenses.gpl2Only;
    maintainers = [ ];
    platforms = platforms.linux;
    broken = lib.versionAtLeast kernel.version "6.2";
  };
}
