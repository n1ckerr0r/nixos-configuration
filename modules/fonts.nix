{ pkgs, ... }:

{
  # Configure system fonts.
  fonts = {
    # Install the default NixOS font set.
    enableDefaultPackages = true;

    # Create a font directory for applications that look up fonts through fontconfig/X11.
    fontDir.enable = true;

    # Install additional fonts.
    packages = with pkgs; [
      # Core Google Noto fonts.
      noto-fonts
      open-sans
      # Noto fonts for Chinese, Japanese and Korean scripts.
      noto-fonts-cjk-sans
      # Noto color emoji fonts.
      noto-fonts-color-emoji
      # Nerd Font glyphs used by terminal tools such as Neovim.
      nerd-fonts._0xproto
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.iosevka
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      font-awesome
    ];
  };
}
