{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      agenix,
      nix-flatpak,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      modules = import ./modules/nixos;
      network = import ../config/network.nix;
      secretsDir = toString ./../secrets;

      # In case we want to, we can override packages from nixpkgs-unstable here using this code snippet.
      # Some examples: tailscale, devenv, etc.
      unstableOverlay = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system};
      };

      mkHost =
        {
          name,
          arch,
          system ? { },
          user ? { },
        }:
        lib.nixosSystem {
          system = arch;
          specialArgs = {
            inherit inputs network;

            hostName = name;
          };
          modules = [
            ./hosts/${name}/hardware-configuration.nix
            modules.system
            modules.graphics
            modules.gaming
            modules.desktops
            modules.software
            modules.services
            agenix.nixosModules.default
            nix-flatpak.nixosModules.nix-flatpak
            system

            # Activate unstable overlay for all hosts.
            {
              nixpkgs.overlays = [ unstableOverlay ];
            }

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = null;
              home-manager.users.connor = {
                imports = [
                  ./modules/home-manager/default.nix
                  user
                  nix-flatpak.homeManagerModules.nix-flatpak
                ];
              };
              home-manager.extraSpecialArgs = {
                inherit inputs;
                hostName = name;
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        aegis = import ./hosts/aegis { inherit mkHost network inputs; };
        artemis = import ./hosts/artemis {
          inherit
            mkHost
            network
            inputs
            secretsDir
            ;
        };
        hermes = import ./hosts/hermes {
          inherit
            mkHost
            network
            inputs
            secretsDir
            ;
        };
        sisyphus = import ./hosts/sisyphus {
          inherit
            mkHost
            network
            inputs
            lib
            secretsDir
            ;
        };
      };
    };
}
