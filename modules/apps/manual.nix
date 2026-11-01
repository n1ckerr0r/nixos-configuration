{ pkgs, ... }:

let
  adguardvpnCli = pkgs.writeShellApplication {
    name = "adguardvpn-cli";
    text = ''
      executable=/opt/adguardvpn_cli/adguardvpn-cli

      if [ ! -x "$executable" ]; then
        echo "adguardvpn-cli: $executable is not installed" >&2
        echo "Install AdGuard VPN CLI manually as described in README.md." >&2
        exit 127
      fi

      exec "$executable" "$@"
    '';
  };

  liveSystemCaptions = pkgs.writeShellApplication {
    name = "live-system-captions-local";
    text = ''
      executable=/home/n1ckerr0r/bin/live-system-captions

      if [ ! -x "$executable" ]; then
        echo "live-system-captions: $executable is not installed" >&2
        echo "Install the local helper manually as described in README.md." >&2
        exit 127
      fi

      exec "$executable" "$@"
    '';
  };
in
{
  # Integrations for software intentionally installed outside Nix live only in
  # this module. Keep the corresponding prerequisites documented in README.md.
  environment.systemPackages = [
    adguardvpnCli
    liveSystemCaptions
  ];

  environment.etc."xdg/applications/live-system-captions.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Live System Captions
    Comment=Transcribe laptop output audio in a small overlay window
    Exec=live-system-captions-local
    Icon=${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/128x128/apps/net.sapples.LiveCaptions.svg
    Terminal=false
    Categories=Utility;AudioVideo;Accessibility;
  '';
}
