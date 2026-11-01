{ pkgs, ... }:

{
  # Create the normal user n1ckerr0r.
  users.users.n1ckerr0r = {
    # Mark the user as a login user, not a system account.
    isNormalUser = true;

    # User description shown by login screens and system tools.
    description = "n1ckerr0r";

    # Pin the login shell for existing and future activations.
    shell = pkgs.zsh;

    # Add the user to NetworkManager, sudo administrators and Docker groups.
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "kvm"
      "ydotool"
    ];

    # Place for packages installed only for this user through NixOS.
    packages = [ ];
  };
}
