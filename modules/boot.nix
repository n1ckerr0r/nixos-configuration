{ pkgs, ... }:

{
  # GRUB is used instead of systemd-boot so the boot screen can use a wallpaper.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    splashImage = ../home/n1ckerr0r/dotfiles/wallpapers/lisau_3.png;
    gfxmodeEfi = "1920x1080";
    configurationLimit = 10;
    useOSProber = false;
    extraEntries = ''
      menuentry "Windows Boot Manager" {
        search --fs-uuid --no-floppy --set=root F6D7-283E
        chainloader /EFI/Microsoft/Boot/bootmgfw.efi
      }
    '';
  };
  boot.loader.timeout = 3;

  # Allow NixOS to write EFI boot entries into firmware.
  boot.loader.efi.canTouchEfiVariables = true;

  # This HONOR/AMD laptop only exposes s2idle. Resume logs repeatedly show an
  # AMD-Vi IO_PAGE_FAULT from the NVMe controller, so keep s2idle and avoid the
  # deepest NVMe power states plus translated DMA on passthrough-capable devices.
  boot.kernelParams = [
    "mem_sleep_default=s2idle"
    "iommu=pt"
    "nvme_core.default_ps_max_latency_us=0"
  ];
  systemd.sleep.settings.Sleep = {
    SuspendState = "mem";
    MemorySleepMode = "s2idle";
  };

  # Keep the laptop running when the lid is closed.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # On this firmware a lid transition wakes s2idle in both directions.  Keep
  # lid wake enabled so opening the laptop still wakes it, but if it resumed
  # while the lid is closed, put it back to sleep after the resume transaction
  # has completed.  Closing the lid during normal use remains ignored by
  # systemd-logind above.
  powerManagement.resumeCommands = ''
    if ${pkgs.gnugrep}/bin/grep -q closed /proc/acpi/button/lid/LID/state; then
      ${pkgs.systemd}/bin/systemd-run \
        --unit=resuspend-closed-lid \
        --collect \
        --no-block \
        --on-active=2s \
        ${pkgs.systemd}/bin/systemctl suspend
    fi
  '';
}
