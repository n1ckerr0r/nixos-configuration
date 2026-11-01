# Home Profile

This directory contains the Home Manager profile for `n1ckerr0r`.

## Entry Points

- `default.nix` embeds Home Manager into the system configuration.
- `profile.nix` imports user-level modules and defines the Home Manager account baseline.

## Desktop Modules

- `desktop/gtk.nix` generates GTK 3 and GTK 4 settings through Home Manager.
- `desktop/kitty.nix` installs Kitty, sets it as the default terminal, and applies `kitty.conf`.
- `desktop/niri.nix` applies the Niri config and provides the startup helper used by Niri.
- `desktop/niri.nix` also defines the Noctalia user service.
- `desktop/zsh.nix` installs zsh plugins and applies XDG-based zsh dotfiles.

## Dotfiles

- `dotfiles/kitty/kitty.conf` configures the Kitty terminal.
- `dotfiles/niri/config.kdl` configures the Niri compositor.
- `dotfiles/zsh/.zshrc` configures the interactive zsh shell.
- `../../assets/wallpapers/` stores wallpapers shared by NixOS and Home Manager.
