{
  # Short flake description shown by nix flake show.
  description = "NixOS configuration for laptop";

  # External sources used by this configuration.
  inputs = {
    # Main NixOS package and module channel.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Keep OnlyOffice on a revision where its recent-folders file picker works.
    # This avoids upgrading the complete system just to update one application.
    onlyoffice-nixpkgs.url = "github:NixOS/nixpkgs/31ecbaca1bdefa45dffc409f0250bd8039ea0010";

    # Discord rejects old desktop builds at runtime. Keep just this application
    # on a recent nixpkgs snapshot without upgrading the rest of the system.
    discord-nixpkgs.url = "tarball+https://github.com/NixOS/nixpkgs/archive/d357a2b54f0b6dc4aeb4e993190a52cf151b6f24.tar.gz";

    # User-level configuration manager.
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Community packaging of Claude Desktop for Linux (not available in nixpkgs).
    claude-desktop = {
      url = "github:aaddrick/claude-desktop-debian";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix packaging of the official Yandex Browser DEB release.
    yandex-browser = {
      url = "github:miuirussia/yandex-browser.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Outputs exported by this flake: the NixOS system and formatter.
  outputs =
    {
      home-manager,
      nixpkgs,
      ...
    }@inputs:
    let
      # Target architecture for this host.
      system = "x86_64-linux";

      # nixpkgs package set for the selected architecture.
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # Formatter used by nix fmt.
      formatter.${system} = pkgs.writeShellApplication {
        name = "nixos-config-format";

        # Commands available inside the formatter script.
        runtimeInputs = [
          pkgs.git
          pkgs.nixfmt
          pkgs.findutils
        ];

        # Format explicit files when provided, otherwise format every tracked *.nix file.
        text = ''
          if [ "$#" -gt 0 ]; then
            nixfmt "$@"
          else
            git ls-files -z '*.nix' | xargs -0 -r nixfmt
          fi
        '';
      };

      # NixOS configuration for the laptop host.
      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        inherit system;

        # Flake inputs available to every module as the inputs argument.
        specialArgs = { inherit inputs; };

        # Host entrypoint that imports shared modules and host-specific settings.
        modules = [
          home-manager.nixosModules.home-manager
          ./hosts/laptop
        ];
      };
    };
}
