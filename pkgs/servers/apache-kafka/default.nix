{ lib, stdenv, fetchurl, jdk17_headless, jdk11_headless, makeWrapper, bash, coreutils, gnugrep, gnused, ps,
  majorVersion ? "1.0" }:

let
  jre11 = jdk11_headless;
  jre   = jdk17_headless;
  versionMap = {
    "3.2" = {
      kafkaVersion = "3.2.1";
      scalaVersion = "2.13";
      sha256 = "440fe73d73ebb78ee0d7accbfd69f53e2281544cf18ea6672c85ef4f6734170b";
      jre = jre;
    };
    "3.1" = {
      kafkaVersion = "3.1.1";
      scalaVersion = "2.13";
      sha256 = "e91e50b0aaa499795a51d984a9d00953f9a2781c51314f47ae4df8b2db1a6c9a";
      jre = jre;
    };
    "3.0" = {
      kafkaVersion = "3.0.1";
      scalaVersion = "2.13";
      sha256 = "1a95abe81dc18eafee65f5bc440ff21ba0c49bd2c6d36bf7878ee8a2e2536097";
      jre = jre;
    };
    "2.8" = {
      kafkaVersion = "2.8.2";
      scalaVersion = "2.13";
      sha256 = "sha256-inZXZJSs8ivtEqF6E/ApoyUHn8vg38wUG3KhowP8mfQ=";
      jre = jre11;
    };

  };
in

with versionMap.${majorVersion};

stdenv.mkDerivation rec {
  version = "${scalaVersion}-${kafkaVersion}";
  pname = "apache-kafka";

  src = fetchurl {
    url = "mirror://apache/kafka/${kafkaVersion}/kafka_${version}.tgz";
    inherit sha256;
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jre bash gnugrep gnused coreutils ps ];

  installPhase = ''
    mkdir -p $out
    cp -R config libs $out

    mkdir -p $out/bin
    cp bin/kafka* $out/bin
    cp bin/connect* $out/bin

    # allow us the specify logging directory using env
    substituteInPlace $out/bin/kafka-run-class.sh \
      --replace 'LOG_DIR="$base_dir/logs"' 'LOG_DIR="$KAFKA_LOG_DIR"'

    substituteInPlace $out/bin/kafka-server-stop.sh \
      --replace 'ps' '${ps}/bin/ps'

    for p in $out/bin\/*.sh; do
      wrapProgram $p \
        --set JAVA_HOME "${jre}" \
        --set KAFKA_LOG_DIR "/tmp/apache-kafka-logs" \
        --prefix PATH : "${bash}/bin:${coreutils}/bin:${gnugrep}/bin:${gnused}/bin"
    done
    chmod +x $out/bin\/*
  '';

  meta = with lib; {
    homepage = "https://kafka.apache.org";
    description = "A high-throughput distributed messaging system";
    license = licenses.asl20;
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    maintainers = [ maintainers.ragge ];
    platforms = platforms.unix;
  };
  passthru = { inherit jre; };
}
