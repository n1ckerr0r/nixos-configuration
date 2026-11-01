{ inputs, pkgs, ... }:

let
  yandexBrowser =
    inputs.yandex-browser.packages.${pkgs.stdenv.hostPlatform.system}.yandex-browser-stable;
  yandexBrowserDirect = pkgs.symlinkJoin {
    name = "yandex-browser-direct";
    paths = [ yandexBrowser ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm "$out/bin/yandex-browser-stable"
      makeWrapper ${yandexBrowser}/bin/yandex-browser-stable "$out/bin/yandex-browser-stable" \
        --add-flags "--proxy-server=socks5://127.0.0.1:1081" \
        --add-flags "--disable-quic" \
        --add-flags "--force-webrtc-ip-handling-policy=disable_non_proxied_udp"

      for desktopFile in "$out/share/applications/"*.desktop; do
        if [ -L "$desktopFile" ]; then
          sourceFile="$(readlink -f "$desktopFile")"
          rm "$desktopFile"
          cp "$sourceFile" "$desktopFile"
        fi
        substituteInPlace "$desktopFile" \
          --replace-fail ${yandexBrowser}/bin/yandex-browser-stable "$out/bin/yandex-browser-stable"
      done
    '';
  };
in
{
  environment.systemPackages = [
    pkgs.google-chrome
    yandexBrowserDirect
  ];
}
