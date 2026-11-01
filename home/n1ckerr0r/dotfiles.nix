{ config, ... }:

let
  configRoot = "${config.home.homeDirectory}/nixos-config";
  dotfilesRoot = "${configRoot}/home/n1ckerr0r/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesRoot}/${path}";
  asset = path: config.lib.file.mkOutOfStoreSymlink "${configRoot}/assets/${path}";
in
{
  # This is the complete map from standard home paths to editable sources.
  # Packages and services stay in Nix; application settings live in dotfiles.
  xdg.configFile = {
    "Code/User/settings.json" = {
      force = true;
      source = link "vscode/settings.json";
    };
    "Code/User/keybindings.json" = {
      force = true;
      source = link "vscode/keybindings.json";
    };
    "alacritty/alacritty.toml" = {
      force = true;
      source = link "alacritty/alacritty.toml";
    };
    "fastfetch/config.jsonc" = {
      force = true;
      source = link "fastfetch/config.jsonc";
    };
    "gtklock/style.css" = {
      force = true;
      source = link "gtklock/style.css";
    };
    "hypr/hyprlock.conf" = {
      force = true;
      source = link "hyprlock/hyprlock.conf";
    };
    "kitty/kitty.conf" = {
      force = true;
      source = link "kitty/kitty.conf";
    };
    "kitty/colors.conf" = {
      force = true;
      source = link "kitty/colors.conf";
    };
    "niri/config.kdl" = {
      force = true;
      source = link "niri/config.kdl";
    };
    "translate-shell/init.trans" = {
      force = true;
      source = link "translate-shell/init.trans";
    };
    "noctalia/settings.json" = {
      force = true;
      source = link "noctalia/settings.json";
    };
    "noctalia/wallpapers.json" = {
      force = true;
      source = link "noctalia/wallpapers.json";
    };
    "noctalia/colorschemes/Catppuccin Mocha Mauve/Catppuccin Mocha Mauve.json" = {
      force = true;
      source = link "noctalia/catppuccin-mocha-mauve.json";
    };
    "noctalia/colorschemes/Tokyo Night/Tokyo Night.json" = {
      force = true;
      source = link "noctalia/tokyo-night.json";
    };
    "nvim" = {
      force = true;
      source = link "nvim";
    };
    "wlogout/layout" = {
      force = true;
      source = link "wlogout/layout";
    };
    "wlogout/style.css" = {
      force = true;
      source = link "wlogout/style.css";
    };
    "zsh" = {
      force = true;
      source = link "zsh";
    };
  };

  home.file = {
    ".zshenv" = {
      force = true;
      source = link "zsh/.zshenv";
    };
    "Pictures/wallpapers/lisau_1.png" = {
      force = true;
      source = asset "wallpapers/lisau_1.png";
    };
    "Pictures/wallpapers/lisau_3.png" = {
      force = true;
      source = asset "wallpapers/lisau_3.png";
    };
    ".local/share/backgrounds/lisau.png" = {
      force = true;
      source = asset "wallpapers/lisau.png";
    };
    ".local/share/backgrounds/lisau_1.png" = {
      force = true;
      source = asset "wallpapers/lisau_1.png";
    };
    ".local/share/backgrounds/lisau_3.png" = {
      force = true;
      source = asset "wallpapers/lisau_3.png";
    };
  };
}
