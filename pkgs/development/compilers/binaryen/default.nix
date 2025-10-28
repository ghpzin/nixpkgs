{
  lib,
  stdenv,
  cmake,
  python3,
  fetchFromGitHub,
  fetchpatch,
  emscripten,
  gtest,
  lit,
  nodejs,
  filecheck,
}:
let
  testsuite = fetchFromGitHub {
    owner = "WebAssembly";
    repo = "testsuite";
    rev = "e05365077e13a1d86ffe77acfb1a835b7aa78422";
    hash = "sha256-yvZ5AZTPUA6nsD3xpFC0VLthiu2CxVto66RTXBXXeJM=";
  };
in
stdenv.mkDerivation rec {
  pname = "binaryen";
  version = "124";

  src = fetchFromGitHub {
    owner = "WebAssembly";
    repo = "binaryen";
    rev = "version_${version}";
    hash = "sha256-tkvO0gNESliRV6FOpXDQd7ZKujGe6q1mGX5V+twcE1o=";
  };

  patches = [
    # Fix build with gcc15
    # https://github.com/WebAssembly/binaryen/issues/7683
    # https://github.com/WebAssembly/binaryen/pull/7979
    (fetchpatch {
      name = "binaryen-ignore-false-gcc-warning-gcc15.patch";
      url = "https://github.com/WebAssembly/binaryen/commit/a7c391581b38a4d49bba9f55b28658ad8af537e2.patch";
      hash = "sha256-9MKexOaCkffdc93UeMqIfV2/EdFmvD/1oo2WVZhf51I=";
    })
  ];

  nativeBuildInputs = [
    cmake
    python3
  ];

  strictDeps = true;

  preConfigure = ''
    if [ $doCheck -eq 1 ]; then
      sed -i '/gtest/d' third_party/CMakeLists.txt
      rmdir test/spec/testsuite
      ln -s ${testsuite} test/spec/testsuite
    else
      cmakeFlagsArray=($cmakeFlagsArray -DBUILD_TESTS=0)
    fi
  '';

  nativeCheckInputs = [
    lit
    nodejs
    filecheck
  ];
  checkInputs = [ gtest ];
  checkPhase = ''
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/lib python3 ../check.py $tests
  '';

  tests = [
    "version"
    "wasm-opt"
    "wasm-dis"
    "crash"
    "dylink"
    "ctor-eval"
    "wasm-metadce"
    "wasm-reduce"
    "spec"
    "lld"
    "wasm2js"
    # "unit" # fails on test.unit.test_cluster_fuzz.ClusterFuzz
    # "binaryenjs" "binaryenjs_wasm" # not building this
    # "lit" # fails on d8/fuzz_shell*
    "gtest"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    "example"
    "validator"
  ];

  doCheck = (stdenv.hostPlatform.isLinux || stdenv.hostPlatform.isDarwin);

  meta = with lib; {
    homepage = "https://github.com/WebAssembly/binaryen";
    description = "Compiler infrastructure and toolchain library for WebAssembly, in C++";
    platforms = platforms.all;
    maintainers = with maintainers; [
      asppsa
      willcohen
    ];
    license = licenses.asl20;
  };
  passthru.tests = { inherit emscripten; };
}
