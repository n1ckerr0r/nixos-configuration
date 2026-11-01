{ inputs, pkgs, ... }:

let
  onlyofficePackage =
    inputs.onlyoffice-nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.onlyoffice-desktopeditors;
  discordPackage =
    (import inputs.discord-nixpkgs {
      system = pkgs.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    }).discord;

  unetbootinIcon = pkgs.fetchurl {
    name = "unetbootin.svg";
    url = "https://upload.wikimedia.org/wikipedia/commons/a/a3/UNetbootin_icon.svg";
    hash = "sha256-CVOIFUUNfokhnvK5tzL6LNAudoJ5Kd4PsZ9WPjOsEsY=";
  };

  # OnlyOffice is a Qt application.  Keep its file chooser native instead of
  # routing it through the globally configured GTK desktop portal.
  onlyoffice = pkgs.symlinkJoin {
    name = "onlyoffice-desktopeditors-native-qt";
    paths = [ onlyofficePackage ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm "$out/bin/onlyoffice-desktopeditors"
      makeWrapper ${onlyofficePackage}/bin/onlyoffice-desktopeditors "$out/bin/onlyoffice-desktopeditors" \
        --unset QT_QPA_PLATFORMTHEME \
        --set GTK_USE_PORTAL 0

      desktopEntry="$out/share/applications/onlyoffice-desktopeditors.desktop"
      rm "$desktopEntry"
      cp ${onlyofficePackage}/share/applications/onlyoffice-desktopeditors.desktop "$desktopEntry"
      substituteInPlace "$desktopEntry" \
        --replace-fail ${onlyofficePackage}/bin/onlyoffice-desktopeditors "$out/bin/onlyoffice-desktopeditors"
    '';
  };

in

{
  # The upstream launcher references a low-resolution legacy icon. Override
  # only the desktop entry and keep the packaged executable unchanged.
  environment.etc."xdg/applications/unetbootin.desktop".text = ''
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=UNetbootin
    Comment=Tool for creating Live USB drives
    Exec=unetbootin_asroot
    Icon=${unetbootinIcon}
    Terminal=false
    Categories=System;Utility;
  '';

  environment.systemPackages = with pkgs; [
    discordPackage
    telegram-desktop
    obsidian
    onlyoffice
    gnome-clocks
    gnome-calculator
    nautilus
    papers
    loupe
    amberol
    celluloid
    obs-studio
    grim
    slurp
    swappy
    wl-clipboard
    zoom-us
    zathura
    textsnatcher
    gparted
    unetbootin
  ];

  # The upstream desktop file names the icon "otd", but the package installs
  # it outside the freedesktop hicolor hierarchy. Use its official bundled
  # artwork by absolute path so launchers can always resolve it.
  environment.etc."xdg/applications/OpenTabletDriver.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Version=1.5
    Name=OpenTabletDriver
    Comment=Open source, cross-platform, user-mode tablet driver
    Exec=otd-gui
    Icon=${pkgs.opentabletdriver}/share/icons/otd.png
    Terminal=false
    Categories=Utility;
  '';
}
