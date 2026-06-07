{
  jre,
  lib,
  stdenvNoCC,
  unzip,
  curl,
  cacert,
  htmlq,
  runCommand,
}:

let
  version = "1.2.0-23522718";
  urlVersion = lib.replaceStrings [ "." ] [ "-" ] version;
  platform = "linux64";
  pname = "necesse-server";
in
stdenvNoCC.mkDerivation {
  inherit pname version;
  src =
    runCommand "${pname}-${platform}-${urlVersion}.zip"
      {
        outputHashAlgo = "sha256";
        outputHash = "sha256-oW57bbmgg99Dmo8nsrIaeWqHNgDjyBOlbGCz+yQCcBU=";
        outputHashMode = "flat";
        nativeBuildInputs = [ curl ];
        SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
        impureEnvVars = lib.fetchers.proxyImpureEnvVars;
      }
      ''
        html=$(curl --silent --url 'https://necessegame.com/server')
        url="$(echo "$html" | ${lib.getExe htmlq} 'a[href*="${pname}-${platform}-${urlVersion}"]' --attribute href)"
        echo "url=$url"
        curl --progress-bar --output $out --url "$url"
      '';
  nativeBuildInputs = [ unzip ];
  sourceRoot = "${pname}-${urlVersion}";

  # removing packaged jre since we use our own
  postUnpack = ''
    rm -rf "$sourceRoot/jre"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r . $out
    params='-nogui "$@"'
    cat >$out/bin/necesse-server <<EOF
    #! $SHELL -e
    exec ${lib.getExe jre} -jar $out/Server.jar $params
    EOF
    chmod +x $out/bin/necesse-server

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    homepage = "https://necessegame.com/server/";
    description = "Dedicated server for Necesse";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.linux;
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "necesse-server";
    maintainers = with lib.maintainers; [ cr0n ];
  };
}
