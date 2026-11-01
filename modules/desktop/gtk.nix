{ pkgs, ... }:

{
  services = {
    # Do not enable GNOME components together with the Niri session.
    gnome.gnome-keyring.enable = false;

    # Register dconf in DBus so GTK applications can read desktop settings.
    dbus.packages = [ pkgs.dconf ];
  };

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    glib
    nwg-look
  ];
}
