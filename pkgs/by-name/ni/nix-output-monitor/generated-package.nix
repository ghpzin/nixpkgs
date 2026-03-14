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
  extra,
  fetchzip,
  filelock,
  filepath,
  hermes-json,
  HUnit,
  lib,
  MemoTrie,
  nix-derivation,
  optics,
  random,
  relude,
  safe,
  safe-exceptions,
  stm,
  streamly-core,
  strict,
  strict-types,
  terminal-size,
  text,
  time,
  transformers,
  typed-process,
  unix,
  word8,
  fetchFromGitHub,
}:
mkDerivation {
  pname = "nix-output-monitor";
  version = "2.1.8";
  src = fetchFromGitHub {
    owner = "maralorn";
    repo = "nix-output-monitor";
    rev = "2e5180152e621ad7e0c0b66ccaa81c82ceab7f2b";
    hash = "sha256-DARjZPYhim9AGSdDsNL2GUfITCG+QSI+jaYMOYooRmU=";
  };
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
    hermes-json
    MemoTrie
    nix-derivation
    optics
    relude
    safe
    safe-exceptions
    stm
    streamly-core
    strict
    strict-types
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
    hermes-json
    MemoTrie
    nix-derivation
    optics
    relude
    safe
    safe-exceptions
    stm
    streamly-core
    strict
    strict-types
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
    extra
    filelock
    filepath
    hermes-json
    HUnit
    MemoTrie
    nix-derivation
    optics
    random
    relude
    safe
    safe-exceptions
    stm
    streamly-core
    strict
    strict-types
    terminal-size
    text
    time
    transformers
    typed-process
    word8
  ];
  homepage = "https://code.maralorn.de/maralorn/nix-output-monitor";
  description = "Processes output of Nix commands to show helpful and pretty information";
  license = lib.licenses.agpl3Plus;
  mainProgram = "nom";
  maintainers = [ lib.maintainers.maralorn ];
}
