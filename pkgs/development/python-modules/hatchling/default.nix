{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder

# runtime
, editables
, importlib-metadata # < 3.8
, packaging
, pathspec
, pluggy
, tomli

# tests
, build
, python
, requests
, toml
, virtualenv
}:

let
  pname = "hatchling";
  version = "0.24.0";
in
buildPythonPackage {
  inherit pname version;
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-zmdl9bW688tX0vgBlsUOIB43KMrNlTU/XJtPA9/fTrk=";
  };

  postPatch = ''
    substituteInPlace ./src/hatchling/ouroboros.py --replace 'tomli>=1.2.2' 'tomli>=1.2.0'
    substituteInPlace ./src/hatchling/ouroboros.py --replace 'packaging>=21.3' 'packaging>=20.9'
  '';

  # listed in backend/src/hatchling/ouroboros.py
  propagatedBuildInputs = [
    editables
    packaging
    pathspec
    pluggy
    tomli
  ] ++ lib.optionals (pythonOlder "3.8") [
    importlib-metadata
  ];

  pythonImportsCheck = [
    "hatchling"
    "hatchling.build"
  ];

  # tries to fetch packages from the internet
  doCheck = false;

  # listed in /backend/tests/downstream/requirements.txt
  checkInputs = [
    build
    packaging
    requests
    toml
    virtualenv
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} tests/downstream/integrate.py
    runHook postCheck
  '';

  meta = with lib; {
    description = "Modern, extensible Python build backend";
    homepage = "https://ofek.dev/hatch/latest/";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa ofek ];
  };
}
