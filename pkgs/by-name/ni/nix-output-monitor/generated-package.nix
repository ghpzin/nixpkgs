# This file has been autogenerate with cabal2nix.
# Update via ./update.sh"
{
  mkDerivation,
  ansi-terminal,
  async,
  attoparsec,
  base,
  bytestring,
  cassava,
  containers,
  directory,
  doctest-parallel,
  extra,
  fetchzip,
  filelock,
  filepath,
  fsnotify,
  hermes-json,
  HUnit,
  lib,
  nix-derivation,
  optics,
  random,
  relude,
  safe,
  safe-exceptions,
  stm,
  streamly-core,
  strict,
  terminal-size,
  text,
  time,
  transformers,
  typed-process,
  unix,
  word8,
}:
mkDerivation {
  pname = "nix-output-monitor";
  version = "2.2.0";
  src = fetchzip {
    url = "https://code.maralorn.de/maralorn/nix-output-monitor/archive/b568a2584ed3619a6ebe41a2910e2bfc674bf836.tar.gz";
    hash = "sha256-t/OKt1G1UnHTRRtNuJ/yC1oOV4Fn39HkNsKzyd3DlYQ=";
  };
  postUnpack = "sourceRoot+=/nix-output-monitor; echo source root reset to $sourceRoot";
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    ansi-terminal
    async
    attoparsec
    base
    bytestring
    cassava
    containers
    directory
    extra
    filelock
    filepath
    fsnotify
    hermes-json
    nix-derivation
    optics
    relude
    safe
    safe-exceptions
    stm
    streamly-core
    strict
    terminal-size
    text
    time
    transformers
    word8
  ];
  executableHaskellDepends = [
    ansi-terminal
    async
    attoparsec
    base
    bytestring
    cassava
    containers
    directory
    extra
    filelock
    filepath
    fsnotify
    hermes-json
    nix-derivation
    optics
    relude
    safe
    safe-exceptions
    stm
    streamly-core
    strict
    terminal-size
    text
    time
    transformers
    typed-process
    unix
    word8
  ];
  testHaskellDepends = [
    ansi-terminal
    async
    attoparsec
    base
    bytestring
    cassava
    containers
    directory
    doctest-parallel
    extra
    filelock
    filepath
    fsnotify
    hermes-json
    HUnit
    nix-derivation
    optics
    random
    relude
    safe
    safe-exceptions
    stm
    streamly-core
    strict
    terminal-size
    text
    time
    transformers
    typed-process
    word8
  ];
  homepage = "https://code.maralorn.de/maralorn/nix-output-monitor";
  description = "Processes output of Nix commands to show helpful and pretty information";
  license = lib.meta.getLicenseFromSpdxId "EUPL-1.2";
  mainProgram = "nom";
  maintainers = [ lib.maintainers.maralorn ];
}
