{ pkgs, ... }:

{
  home = {
    packages = [ pkgs.kitty ];
    sessionVariables.TERMINAL = "kitty";
  };
}
