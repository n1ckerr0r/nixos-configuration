{ pkgs, ... }:

{
  # Enable zsh as an available system login shell.
  programs.zsh.enable = true;

  # Use zsh as the default shell for users without an explicit shell.
  users.defaultUserShell = pkgs.zsh;
}
