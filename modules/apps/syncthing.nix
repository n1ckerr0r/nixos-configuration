{ pkgs, ... }:

{
  # Syncthing is currently used as an on-demand application. This deliberately
  # installs the program without enabling a system daemon.
  environment.systemPackages = [ pkgs.syncthing ];
}
