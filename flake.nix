{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";
  
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }@inputs:     
    let
      lib = nixpkgs.lib;

      # syncthing device IDs
      devices = {
        sisyphus = "XGVROJR-NJ7EVPU-4HK6TXO-345J6P4-GQJQAYN-KFNDXXV-OAJQ365-U3K3TQJ";
        artemis  = "E4TZ7AC-Y3GVSSY-TTRTR5G-5HAZRUK-ICYT2GO-7FDVOL3-5XUFVM7-YH5NMQC";
      };
    in {
      nixosConfigurations = {
        desktop = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit inputs devices;};
          modules = [
            ./hosts/desktop

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.connor = ./home-manager/default.nix;
            }
            
            # Make the config available to home-manager
            ({ config, ... }: {
              home-manager.extraSpecialArgs = {
                inherit inputs;
                gnomeEnabled = config.gnome.enable;
              };
            })

            sops-nix.nixosModules.sops

          ];
        };

        laptop = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit inputs devices;};
          modules = [
            ./hosts/laptop

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.connor = ./home-manager/default.nix;
            }

            # Make the config available to home-manager
            ({ config, ... }: {
              home-manager.extraSpecialArgs = {
                inherit inputs;
                gnomeEnabled = config.gnome.enable;
              };
            })

            sops-nix.nixosModules.sops

          ];
        };

        server = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit inputs devices;};
          modules = [
            ./hosts/server

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.connor = ./home-manager/default.nix;
            }

            # Make the config available to home-manager
            ({ config, ... }: {
              home-manager.extraSpecialArgs = {
                inherit inputs;
                gnomeEnabled = config.gnome.enable;
              };
            })

            sops-nix.nixosModules.sops

          ];
        };

      };
    };
}
