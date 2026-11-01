{
  config,
  lib,
  modulesPath,
  ...
}:

{
  # Import fallback modules for hardware that was not detected automatically.
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    # Kernel modules initrd needs for early disk and USB/Thunderbolt access.
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "usb_storage"
      "sd_mod"
    ];

    # No extra initrd modules are needed now.
    initrd.kernelModules = [ ];

    # Enable AMD hardware virtualization support.
    kernelModules = [ "kvm-amd" ];

    # No extra kernel module packages are used now.
    extraModulePackages = [ ];
  };

  # Root filesystem.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/89e4ae30-c42a-4515-820a-cd85b2bb3dc7";
    fsType = "ext4";
  };

  # EFI partition used by GRUB.
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/F6D7-283E";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  # No swap partitions or swap files are configured.
  swapDevices = [ ];

  # System platform detected by the NixOS generator.
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Update AMD microcode when redistributable firmware is enabled.
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
