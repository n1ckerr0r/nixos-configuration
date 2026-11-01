{ ... }:

{
  # Pin the NixOS version that controls stateful defaults and migrations.
  system.stateVersion = "25.11";

  # Enable the modern nix command and flake support.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Provide the standard dynamic loader for third-party Linux binaries,
  # including the native Claude Code executable shipped by the VS Code extension.
  programs.nix-ld.enable = true;

  # Enable NetworkManager for Wi-Fi, Ethernet and VPN management.
  networking.networkmanager.enable = true;

  # Set the system time zone.
  time.timeZone = "Europe/Moscow";

  # Set the primary system locale.
  i18n.defaultLocale = "ru_RU.UTF-8";

  # Allow installation of unfree packages.
  nixpkgs.config.allowUnfree = true;

  # Required by androidenv packages for the Android SDK and emulator.
  nixpkgs.config.android_sdk.accept_license = true;
}
