{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nil
    nixd
    nixfmt
    statix
    deadnix
  ];
}
