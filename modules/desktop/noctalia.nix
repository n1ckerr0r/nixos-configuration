{ pkgs, ... }:

let
  noctaliaShell = pkgs.noctalia-shell.overrideAttrs (oldAttrs: {
    postPatch = (oldAttrs.postPatch or "") + ''
      patch -p3 < ${../../home/n1ckerr0r/dotfiles/noctalia/patches/floating-glass-popups.patch}
      substituteInPlace Commons/Style.qml \
        --replace-fail 'h = (Settings.data.bar.position === "left" || Settings.data.bar.position === "right") ? 49 : 47;' 'h = (Settings.data.bar.position === "left" || Settings.data.bar.position === "right") ? 37 : 35;' \
        --replace-fail 'h = isVertical ? 49 : 47;' 'h = isVertical ? 37 : 35;' \
        --replace-fail 'h = Math.round(barHeight * 0.65);' 'h = Math.round(barHeight * 0.88);'
    '';
  });
in

{
  # Polkit is needed for GUI privilege prompts without a full desktop shell.
  security.polkit = {
    enable = true;
    enablePkexecWrapper = true;
  };

  services = {
    # Required by Noctalia battery and power-profile widgets, plus the
    # standalone Bluetooth applet used in the Niri session.
    upower.enable = true;
    power-profiles-daemon.enable = true;
    blueman.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
  };

  hardware.bluetooth.enable = true;

  environment = {
    systemPackages = with pkgs; [
      noctaliaShell
      playerctl
      brightnessctl
      pavucontrol
      blueman
      lxqt.lxqt-policykit
      wlsunset
    ];

    sessionVariables.NOCTALIA_PAM_SERVICE = "login";
  };
}
