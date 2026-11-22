{
  description = "NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    agenix.url = "github:ryantm/agenix";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pi = {
      url = "github:earendil-works/pi";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # dux
    dux-plugin-registry = {
      url = "github:duxlabs-dev/dux-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      home-manager-unstable,
      agenix,
      nix-flatpak,
      disko,
      ...
    }@inputs:
    let
      modules = import ./modules/nixos;
      network = import ../config/network.nix;
      secrets = ./../secrets;

      # each host tracks one channel, which decides the nixpkgs and home-manager it is built with.
      channels = {
        stable = {
          nixpkgs = nixpkgs;
          home-manager = home-manager;
        };
        unstable = {
          nixpkgs = nixpkgs-unstable;
          home-manager = home-manager-unstable;
        };
      };

      unstableOverlay = final: prev: {
        unstable = import nixpkgs-unstable {
          system = prev.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
      };

      mkHost =
        {
          name,
          arch,
          channel ? "stable",
          system ? { },
          user ? { },
        }:
        channels.${channel}.nixpkgs.lib.nixosSystem {
          system = arch;
          specialArgs = {
            inherit
              inputs
              network
              secrets
              channel
              ;

            hostName = name;
          };
          modules = [
            ./hosts/${name}/hardware-configuration.nix
            ./hosts/${name}/disk.nix
            modules.system
            modules.graphics
            modules.gaming
            modules.gui
            modules.software
            modules.services
            agenix.nixosModules.default
            disko.nixosModules.disko
            nix-flatpak.nixosModules.nix-flatpak
            system

            # activate unstable overlay for all hosts, so pkgs.unstable works on every channel.
            {
              nixpkgs.overlays = [ unstableOverlay ];
            }

            channels.${channel}.home-manager.nixosModules.home-manager
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
                inherit inputs channel;
                hostName = name;
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        aegis = import ./hosts/aegis {
          inherit
            mkHost
            network
            inputs
            secrets
            ;
        };
        artemis = import ./hosts/artemis {
          inherit
            mkHost
            network
            inputs
            secrets
            ;
        };
        hermes = import ./hosts/hermes {
          inherit
            mkHost
            network
            inputs
            secrets
            ;
        };
        sisyphus = import ./hosts/sisyphus {
          inherit
            mkHost
            network
            inputs
            secrets
            ;
        };
      };
    };
}
