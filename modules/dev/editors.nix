{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim-full
    neovide
    vscode
  ];
}
