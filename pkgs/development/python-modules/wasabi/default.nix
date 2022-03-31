{ lib
, buildPythonPackage
, fetchPypi
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "wasabi";
  version = "0.9.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-rabxPptw7ya/lfrQ/r396+IAXimgitWPS7rjg6lymM8=";
  };

  checkInputs = [ pytestCheckHook ];

  meta = with lib; {
    description = "A lightweight console printing and formatting toolkit";
    homepage = "https://github.com/ines/wasabi";
    changelog = "https://github.com/ines/wasabi/releases/tag/v${version}";
    license = licenses.mit;
  };
}
