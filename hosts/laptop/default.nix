_:

{
  imports = [
    ./hardware-configuration.nix
    ./network.nix

    ../../modules/core.nix
    ../../modules/boot.nix
    ../../modules/fonts.nix

    ../../modules/desktop/gtk.nix
    ../../modules/desktop/niri.nix
    ../../modules/desktop/noctalia.nix
    ../../modules/desktop/portals.nix
    ../../modules/desktop/sddm.nix

    ../../modules/input/keyboard.nix
    ../../modules/input/keyd.nix
    ../../modules/input/tablet.nix

    ../../modules/shell/zsh.nix

    ../../modules/users/n1ckerr0r.nix
    ../../home/n1ckerr0r

    ../../modules/profile.nix
    ../../modules/start.nix

    ../../modules/apps/adguardvpn.nix
    ../../modules/apps/browsers.nix
    ../../modules/apps/claude.nix
    ../../modules/apps/cli.nix
    ../../modules/apps/deb.nix
    ../../modules/apps/manual.nix
    ../../modules/apps/ui.nix

    ../../modules/dev

    ../../modules/services/audio.nix
    ../../modules/services/databases.nix
    ../../modules/services/docker.nix
    ../../modules/services/monitoring.nix
    ../../modules/services/memory-pressure.nix
    ../../modules/services/ollama.nix
    ../../modules/services/printing.nix
    ../../modules/apps/syncthing.nix
  ];
}
