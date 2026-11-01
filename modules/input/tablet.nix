{ ... }:

{
  # XP-Pen Deco tablets work more predictably through OpenTabletDriver on NixOS:
  # it installs the GUI/daemon, udev rules and masks conflicting kernel drivers.
  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
  };
}
