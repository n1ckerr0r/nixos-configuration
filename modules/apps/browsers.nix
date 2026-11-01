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
  telemostIcon = pkgs.fetchurl {
    name = "yandex-telemost.svg";
    url = "https://upload.wikimedia.org/wikipedia/commons/f/f9/Yandex_Telemost_icon.svg";
    hash = "sha256-PiUvfB3kbgiVsGD6mjP0Cz19lzFzOjA1rT2Tpc7raFU=";
  };
in
{

  # Telemost has no Linux desktop release.  This starts its supported web client
  # in a separate application window and exposes it in the application menu.
  environment.systemPackages = [
    pkgs.google-chrome
    yandexBrowserDirect
    (pkgs.writeShellApplication {
      name = "telemost";
      runtimeInputs = [ yandexBrowserDirect ];
      text = ''
        exec yandex-browser-stable --app=https://telemost.yandex.ru "$@"
      '';
    })
  ];

  environment.etc."xdg/applications/telemost.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Yandex Telemost
    Comment=Yandex Telemost web application
    Exec=telemost
    Icon=${telemostIcon}
    Terminal=false
    Categories=Network;VideoConference;
  '';
}
