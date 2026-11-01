{ lib, pkgs, ... }:

{
  # Portals provide file pickers, screen sharing and desktop integration for
  # sandboxed or Wayland-native applications running inside the Niri session.
  xdg.portal = {
    enable = true;

    extraPortals = lib.mkForce [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];

    config.niri = lib.mkForce {
      default = [
        "gnome"
        "gtk"
      ];
      "org.freedesktop.impl.portal.FileChooser" = "gnome";
      "org.freedesktop.impl.portal.Access" = "gtk";
      "org.freedesktop.impl.portal.Notification" = "gtk";
      "org.freedesktop.impl.portal.ScreenCast" = "gnome";
      "org.freedesktop.impl.portal.Screenshot" = "gnome";
    };
  };

  environment.sessionVariables = {
    # Make non-sandboxed GTK and Qt applications prefer portal dialogs too.
    GTK_USE_PORTAL = "1";
    QT_QPA_PLATFORMTHEME = "xdgdesktopportal";
  };
}
