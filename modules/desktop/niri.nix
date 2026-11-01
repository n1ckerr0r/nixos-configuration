{ pkgs, ... }:

{
  security.pam.services.hyprlock = { };

  # Enable Niri as the primary Wayland session. Session startup details,
  # portals and shell widgets are split into neighboring desktop modules.
  programs.niri = {
    enable = true;
    useNautilus = false;
  };

  # Allow the desktop-control MCP server to inject pointer events on Wayland.
  programs.ydotool.enable = true;

  environment = {
    systemPackages = with pkgs; [
      xwayland-satellite
      hyprlock
      wtype
    ];

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_DESKTOP = "niri";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };
  };
}
