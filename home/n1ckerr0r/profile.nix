{ inputs, pkgs, ... }:

let
  codexPackage = pkgs.stdenvNoCC.mkDerivation {
    pname = "codex";
    version = "0.166.0";

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@openai/codex/-/codex-0.166.0-linux-x64.tgz";
      hash = "sha512-CxDm3+D1cpbGJeHrdzINoG+3wn9BVncP4qpZaaNYkxe8iPtRJOYyCJnnPoVjWRIBvI9vPKbRoifsMSA5xDaUpw==";
    };

    sourceRoot = "package";
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/bin" "$out/libexec/codex"
      cp -R vendor/x86_64-unknown-linux-musl/. "$out/libexec/codex/"
      ln -s "$out/libexec/codex/bin/codex" "$out/bin/codex"

      runHook postInstall
    '';

    meta = {
      description = "Lightweight coding agent that runs in your terminal";
      homepage = "https://github.com/openai/codex";
      license = pkgs.lib.licenses.asl20;
      mainProgram = "codex";
      platforms = [ "x86_64-linux" ];
    };
  };

  discordPackage =
    (import inputs.discord-nixpkgs {
      system = pkgs.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    }).discord;
in

{
  # User-level modules are split by application or desktop integration area.
  imports = [
    ./dotfiles.nix
    ./desktop/gtk.nix
    ./desktop/alacritty.nix
    ./desktop/kitty.nix
    ./desktop/niri.nix
    ./desktop/zsh.nix
  ];

  # Home Manager identity and compatibility baseline for this account.
  home = {
    username = "n1ckerr0r";
    homeDirectory = "/home/n1ckerr0r";
    stateVersion = "25.11";
    sessionPath = [ "$HOME/.local/bin" ];
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    codexPackage
    translate-shell
    chromium
    discordPackage
  ];

  # Keep the official client ahead of the legacy system-level Vesktop wrapper
  # until the next NixOS switch removes that wrapper from the system profile.
  home.file.".local/bin/discord".source = "${discordPackage}/bin/discord";

  xdg.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      "application/pdf" = [ "org.gnome.Papers.desktop" ];
      "image/png" = [ "org.gnome.Loupe.desktop" ];
      "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
      "image/jpg" = [ "org.gnome.Loupe.desktop" ];
      "image/webp" = [ "org.gnome.Loupe.desktop" ];
      "image/gif" = [ "org.gnome.Loupe.desktop" ];
      "text/html" = [ "google-chrome.desktop" ];
      "application/xhtml+xml" = [ "google-chrome.desktop" ];
      "x-scheme-handler/http" = [ "google-chrome.desktop" ];
      "x-scheme-handler/https" = [ "google-chrome.desktop" ];
      "x-scheme-handler/about" = [ "google-chrome.desktop" ];
      "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
      "video/mp4" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "video/x-matroska" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "video/x-msvideo" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "video/webm" = [ "io.github.celluloid_player.Celluloid.desktop" ];
    };
  };
}
