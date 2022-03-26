{ lib, stdenv
, fetchurl
, fetchpatch

, autoreconfHook
, pkg-config

, libdeflate
, libjpeg
, xz
, zlib

, Cocoa
, GLUT
, libGL
, libGLU
}:

#FIXME: fix aarch64-darwin build and get rid of ./aarch64-darwin.nix

stdenv.mkDerivation rec {
  pname = "libtiff";
  version = "4.3.0";

  src = fetchurl {
    url = "https://download.osgeo.org/libtiff/tiff-${version}.tar.gz";
    sha256 = "1j3snghqjbhwmnm5vz3dr1zm68dj15mgbx1wqld7vkl7n2nfaihf";
  };

  patches = [
    # FreeImage needs this patch
    ./headers.patch
    # libc++abi 11 has an `#include <version>`, this picks up files name
    # `version` in the project's include paths
    ./rename-version.patch
    (fetchpatch {
      name = "CVE-2022-22844.patch";
      url = "https://gitlab.com/libtiff/libtiff/-/commit/03047a26952a82daaa0792957ce211e0aa51bc64.patch";
      sha256 = "0cfih55f5qpc84mvlwsffik80bgz6drkflkhrdyqq8m84jw3mbwb";
    })
    (fetchpatch {
      name = "CVE-2022-0561.patch";
      url = "https://gitlab.com/libtiff/libtiff/-/commit/eecb0712f4c3a5b449f70c57988260a667ddbdef.patch";
      sha256 = "0m57fdxyvhhr9cc260lvkkn2g4zr4n4v9nricc6lf9h6diagd7mk";
    })
    (fetchpatch {
      name = "CVE-2022-0562.patch";
      url = "https://gitlab.com/libtiff/libtiff/-/commit/561599c99f987dc32ae110370cfdd7df7975586b.patch";
      sha256 = "0ycirjjc1vigj03kwjb92n6jszsl9p17ccw5hry7lli9gxyyr0an";
    })
    (fetchpatch {
      name = "CVE-2022-0891.patch";
      url = "https://gitlab.com/libtiff/libtiff/-/commit/46dc8fcd4d38c3b6f35ab28e532aee80e6f609d6.patch";
      sha256 = "1zn2pgsmbrjx3g2bpdggvwwbp6i348mikwlx4ws482h2379vmyj1";
    })
    (fetchpatch {
      name = "CVE-2022-0865.patch";
      url = "https://gitlab.com/libtiff/libtiff/-/commit/5e18004500cda10d9074bdb6166b054e95b659ed.patch";
      sha256 = "131b9ial6avl2agwk31wp2jkrx59955f4r0dikx1jdaywqb7zhd1";
    })
    (fetchpatch {
      name = "CVE-2022-0924.patch";
      url = "https://gitlab.com/libtiff/libtiff/-/commit/408976c44ef0aad975e0d1b6c6dc80d60f9dc665.patch";
      sha256 = "1aqaynp74ijxr3rizvbyz23ncs71pbbcw5src1zv46473sy55s8p";
    })
    (fetchpatch {
      name = "CVE-2022-0907.patch";
      url = "https://gitlab.com/libtiff/libtiff/-/commit/f2b656e2e64adde07a6cffd5c8e96bd81a850fea.patch";
      sha256 = "0nsplq671qx0f35qww9mx27raqp3nvslz8iv7f3hxdgldylmh2vs";
    })
    (fetchpatch {
      name = "CVE-2022-0909.patch";
      url = "https://gitlab.com/libtiff/libtiff/-/commit/f8d0f9aa1ba04c9ae3bfe869a18141a8b8117ad7.patch";
      sha256 = "1plhk6ildl16bp0k3wvzfd4a97hqfqfbbn7vjinsaasf4v0x3q5j";
    })
    (fetchpatch {
      name = "CVE-2022-0908.patch";
      url = "https://gitlab.com/libtiff/libtiff/-/commit/a95b799f65064e4ba2e2dfc206808f86faf93e85.patch";
      sha256 = "0i61kkjaixdn2p933lpma9s6i0772vhxjxxcwyqagw96lmszrcm7";
    })
  ];

  postPatch = ''
    mv VERSION VERSION.txt
  '';

  outputs = [ "bin" "dev" "dev_private" "out" "man" "doc" ];

  postFixup = ''
    moveToOutput include/tif_dir.h $dev_private
    moveToOutput include/tif_config.h $dev_private
    moveToOutput include/tiffiop.h $dev_private
  '';

  # If you want to change to a different build system, please make
  # sure cross-compilation works first!
  nativeBuildInputs = [ autoreconfHook pkg-config ];

  propagatedBuildInputs = [ libjpeg xz zlib ]; #TODO: opengl support (bogus configure detection)

  buildInputs = [ libdeflate ] # TODO: move all propagatedBuildInputs to buildInputs.
    ++ lib.optionals (stdenv.isDarwin) [ Cocoa GLUT libGL libGLU ];

  enableParallelBuilding = true;

  doCheck = true;

  meta = with lib; {
    description = "Library and utilities for working with the TIFF image file format";
    homepage = "https://libtiff.gitlab.io/libtiff";
    changelog = "https://libtiff.gitlab.io/libtiff/v${version}.html";
    maintainers = with maintainers; [ qyliss ];
    license = licenses.libtiff;
    platforms = platforms.unix;
  };
}
