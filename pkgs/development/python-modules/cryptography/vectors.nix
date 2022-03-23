{ buildPythonPackage, fetchPypi, lib, cryptography }:

buildPythonPackage rec {
  pname = "cryptography-vectors";
  # The test vectors must have the same version as the cryptography package
  inherit (cryptography) version;

  src = fetchPypi {
    pname = "cryptography_vectors";
    inherit version;
    sha256 = "sha256-TIRBAleZPT3gWLRLd3pJ4doq416+opcKNgx+OqD1gPI=";
  };

  # No tests included
  doCheck = false;

  pythonImportsCheck = [ "cryptography_vectors" ];

  meta = with lib; {
    description = "Test vectors for the cryptography package";
    homepage = "https://cryptography.io/en/latest/development/test-vectors/";
    # Source: https://github.com/pyca/cryptography/tree/master/vectors;
    license = with licenses; [ asl20 bsd3 ];
    maintainers = with maintainers; [ primeos ];
  };
}
