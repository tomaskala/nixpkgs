{ lib
, stdenv
, buildPythonPackage
, fetchPypi
, argon2_cffi
, bcrypt
, cryptography
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "passlib";
  version = "1.7.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "defd50f72b65c5402ab2c573830a6978e5f202ad0d984793c8dde2c4152ebe04";
  };

  passthru.extras-require = {
    argon2 = [ argon2_cffi ];
    bcrypt = [ bcrypt ];
    totp = [ cryptography ];
  };

  checkInputs = [
    pytestCheckHook
  ] ++ passthru.extras-require.argon2
    ++ passthru.extras-require.bcrypt
    ++ passthru.extras-require.totp;

  disabledTests = [
    # timming sensitive
    "test_dummy_verify"
  ]
  # These tests fail because they don't expect support for algorithms provided through libxcrypt
  ++ lib.optionals stdenv.isDarwin [
    "test_82_crypt_support"
  ];

  meta = with lib; {
    description = "A password hashing library for Python";
    homepage = "https://foss.heptapod.net/python-libs/passlib";
    license = licenses.bsdOriginal;
    maintainers = with maintainers; [ ];
  };
}
