{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    walls = {
      url = "github:dharmx/walls";
      flake = false;
    };

    flox = {
      url = "github:flox/flox/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, walls, flox, ... }@inputs:     
    let
      lib = nixpkgs.lib;

      # anytypeAppImage = {
      #   version = "0.50.5";
      #   url = "https://downloads.sourceforge.net/project/anytype.mirror/v0.50.5/Anytype-0.50.5.AppImage";
      #   sha256 = "";
      # };

      # syncthing device IDs
      devices = {
        sisyphus = "XGVROJR-NJ7EVPU-4HK6TXO-345J6P4-GQJQAYN-KFNDXXV-OAJQ365-U3K3TQJ";
        artemis  = "E4TZ7AC-Y3GVSSY-TTRTR5G-5HAZRUK-ICYT2GO-7FDVOL3-5XUFVM7-YH5NMQC";
      };

      commonSpecialArgs = {inherit inputs walls devices;};

    in {
      nixosConfigurations = {
        desktop = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = commonSpecialArgs;
          modules = [
            ./hosts/desktop

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.connor = ./home-manager/default.nix;
              home-manager.backupFileExtension = "backup";
            }
            
            ({ config, ... }: {
              home-manager.extraSpecialArgs = {
                inherit inputs;
              
                # Make the config available to home-manager
                systemOptions = config;
                # anytypeAppImage = anytypeAppImage;
              };
            })

            sops-nix.nixosModules.sops

          ];
        };

        laptop = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = commonSpecialArgs;
          modules = [
            ./hosts/laptop

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.connor = ./home-manager/default.nix;
              home-manager.backupFileExtension = "backup";
            }

            # Make the config available to home-manager
            ({ config, ... }: {
              home-manager.extraSpecialArgs = {
                inherit inputs;
                
                # Make the config available to home-manager
                systemOptions = config;
                # # anytypeAppImage = anytypeAppImage;
              };
            })

            sops-nix.nixosModules.sops

          ];
        };

        server = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = commonSpecialArgs;
          modules = [
            ./hosts/server

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.connor = ./home-manager/default.nix;
              home-manager.backupFileExtension = "backup";
            }

            ({ config, ... }: {
              home-manager.extraSpecialArgs = {
                inherit inputs;
                
                # Make the config available to home-manager
                systemOptions = config;
                # # anytypeAppImage = anytypeAppImage;
              };
            })

            sops-nix.nixosModules.sops

          ];
        };

      };
    };
}
