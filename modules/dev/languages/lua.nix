{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    lua-language-server
    lua5_4
    lua54Packages.luacheck
    lua54Packages.busted
    stylua
  ];
}
