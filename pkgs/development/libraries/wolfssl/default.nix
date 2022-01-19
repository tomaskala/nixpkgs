{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, autoreconfHook
}:

stdenv.mkDerivation rec {
  pname = "wolfssl";
  version = "5.1.1";

  src = fetchFromGitHub {
    owner = "wolfSSL";
    repo = "wolfssl";
    rev = "v${version}-stable";
    sha256 = "sha256-/noS5cn8lllWoGyZ9QyjRmdiR6LXzfT4lYGEt+0+Bdw=";
  };

  patches = [
    (fetchpatch {
      name = "CVE-2022-23408.patch";
      url = "https://github.com/wolfSSL/wolfssl/commit/73b4cc9476f6355a91138f545f3fd007ce058255.patch";
      sha256 = "0r3z6ybmx3ylnw9zdva3gq4jy691r471qvhy6dvdgmdksh2kx63v";
    })
  ];

  # Almost same as Debian but for now using --enable-all --enable-reproducible-build instead of --enable-distro to ensure options.h gets installed
  configureFlags = [
    "--enable-all"
    "--enable-base64encode"
    "--enable-pkcs11"
    "--enable-writedup"
    "--enable-reproducible-build"
    "--enable-tls13"
  ];

  outputs = [
    "dev"
    "doc"
    "lib"
    "out"
  ];

  nativeBuildInputs = [
    autoreconfHook
  ];

  postInstall = ''
     # fix recursive cycle:
     # wolfssl-config points to dev, dev propagates bin
     moveToOutput bin/wolfssl-config "$dev"
     # moveToOutput also removes "$out" so recreate it
     mkdir -p "$out"
  '';

  meta = with lib; {
    description = "A small, fast, portable implementation of TLS/SSL for embedded devices";
    homepage = "https://www.wolfssl.com/";
    platforms = platforms.all;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ fab ];
  };
}
