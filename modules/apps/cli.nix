{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    asciiquarium-transparent
    btop
    cbonsai
    cmatrix
    lolcat
    openvpn
    onefetch
    pipes-rs
    speedtest-cli
    tty-clock
    unzip
    zip
    tesseract
    xdg-utils
  ];
}
