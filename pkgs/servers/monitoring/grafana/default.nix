{ lib, buildGo117Module, fetchurl, fetchFromGitHub, nixosTests, tzdata, wire }:

buildGo117Module rec {
  pname = "grafana";
  version = "8.4.7";

  excludedPackages = "\\(alert_webhook_listener\\|clean-swagger\\|release_publisher\\|slow_proxy\\|slow_proxy_mac\\|macaron\\)";

  src = fetchFromGitHub {
    rev = "v${version}";
    owner = "grafana";
    repo = "grafana";
    sha256 = "sha256-8owcfWTiXhejFc5P0AM6POXBXuAABn4M/uX9X68Zn8k=";
  };

  srcStatic = fetchurl {
    url = "https://dl.grafana.com/oss/release/grafana-${version}.linux-amd64.tar.gz";
    sha256 = "1wi28v1xhav8p2jqkf2gmk1accfcf1w0d6h312d4pns6pkhdabxv";
  };

  patches = [
    # https://github.com/grafana/grafana/commit/2f756845006820de4ad2b33e4be8338b81217d41, but
    # rebased onto 8.4.x
    ./CVE-2022-29170.patch
  ];

  vendorSha256 = "sha256-7ZeOncdiA/0Awg+olJvsLneLQH4zBQka4M81jsxwUdE=";

  nativeBuildInputs = [ wire ];

  preBuild = ''
    # Generate DI code that's required to compile the package.
    # From https://github.com/grafana/grafana/blob/v8.2.3/Makefile#L33-L35
    wire gen -tags oss ./pkg/server
    wire gen -tags oss ./pkg/cmd/grafana-cli/runner

    # The testcase makes an API call against grafana.com:
    #
    # [...]
    # grafana> t=2021-12-02T14:24:58+0000 lvl=dbug msg="Failed to get latest.json repo from github.com" logger=update.checker error="Get \"https://raw.githubusercontent.com/grafana/grafana/main/latest.json\": dial tcp: lookup raw.githubusercontent.com on [::1]:53: read udp [::1]:36391->[::1]:53: read: connection refused"
    # grafana> t=2021-12-02T14:24:58+0000 lvl=dbug msg="Failed to get plugins repo from grafana.com" logger=plugin.manager error="Get \"https://grafana.com/api/plugins/versioncheck?slugIn=&grafanaVersion=\": dial tcp: lookup grafana.com on [::1]:53: read udp [::1]:41796->[::1]:53: read: connection refused"
    sed -i -e '/Request is not forbidden if from an admin/a t.Skip();' pkg/tests/api/plugins/api_plugins_test.go

    # Skip a flaky test (https://github.com/NixOS/nixpkgs/pull/126928#issuecomment-861424128)
    sed -i -e '/it should change folder successfully and return correct result/{N;s/$/\nt.Skip();/}'\
      pkg/services/libraryelements/libraryelements_patch_test.go


    # main module (github.com/grafana/grafana) does not contain package github.com/grafana/grafana/scripts/go
    rm -r scripts/go
  '';

  ldflags = [
    "-s" "-w" "-X main.version=${version}"
  ];

  # Tests start http servers which need to bind to local addresses:
  # panic: httptest: failed to listen on a port: listen tcp6 [::1]:0: bind: operation not permitted
  __darwinAllowLocalNetworking = true;

  # On Darwin, files under /usr/share/zoneinfo exist, but fail to open in sandbox:
  # TestValueAsTimezone: date_formats_test.go:33: Invalid has err for input "Europe/Amsterdam": operation not permitted
  preCheck = ''
    export ZONEINFO=${tzdata}/share/zoneinfo
  '';

  postInstall = ''
    tar -xvf $srcStatic
    mkdir -p $out/share/grafana
    mv grafana-*/{public,conf,tools} $out/share/grafana/

    cp ./conf/defaults.ini $out/share/grafana/conf/
  '';

  passthru.tests = { inherit (nixosTests) grafana; };

  meta = with lib; {
    description = "Gorgeous metric viz, dashboards & editors for Graphite, InfluxDB & OpenTSDB";
    license = licenses.agpl3;
    homepage = "https://grafana.com";
    maintainers = with maintainers; [ offline fpletz willibutz globin ma27 Frostman ];
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "grafana-server";
  };
}
