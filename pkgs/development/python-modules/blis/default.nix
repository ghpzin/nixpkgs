{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,
  cython,
  numpy,

  # tests
  hypothesis,
  pytestCheckHook,

  # passthru
  blis,
  numpy_1,
  gitUpdater,
}:

buildPythonPackage rec {
  pname = "blis";
  version = "1.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "explosion";
    repo = "cython-blis";
    tag = "release-v${version}";
    hash = "sha256-mSIfFjnLhPLqSNLHMS5gTeAmqmNfXpcbyH7ejv4YgQU=";
  };

  build-system = [
    setuptools
    cython
    numpy
  ];

  # Fix build with gcc15
  # https://github.com/explosion/cython-blis/issues/127
  env.BLIS_ARCH = "generic";

  dependencies = [ numpy ];

  pythonImportsCheck = [ "blis" ];

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  # remove src module, so tests use the installed module instead
  preCheck = ''
    rm -rf ./blis
  '';

  disabledTestPaths = [
    # ImportError: cannot import name 'NO_CONJUGATE' from 'blis.cy'
    "tests/test_dotv.py"
  ];

  passthru = {
    tests = {
      numpy_1 = blis.overridePythonAttrs (old: {
        numpy = numpy_1;
      });
    };
    updateScript = gitUpdater {
      rev-prefix = "release-v";
    };
  };

  meta = {
    changelog = "https://github.com/explosion/cython-blis/releases/tag/release-v${version}";
    description = "BLAS-like linear algebra library";
    homepage = "https://github.com/explosion/cython-blis";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}
