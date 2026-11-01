{ pkgs, ... }:

{
  gtk = {
    enable = true;

    # Match GTK 3 applications to GTK 4/libadwaita dialogs instead of falling
    # back to an incomplete theme that is not installed on the system.
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };

    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4 = {
      # GTK 4/libadwaita has its own native styling; forcing a GTK 3 theme on
      # it causes the mismatched controls seen in portal file choosers.
      theme = null;
      extraConfig.gtk-application-prefer-dark-theme = 1;
    };
  };

  dconf.enable = true;

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "adw-gtk3-dark";
    icon-theme = "Papirus-Dark";
  };
}
