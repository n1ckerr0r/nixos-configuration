{ inputs, ... }:

{
  # Home Manager is embedded into the NixOS configuration so the user profile is
  # rebuilt together with the system.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "hm-backup";
    users.n1ckerr0r = import ./profile.nix;
  };
}
