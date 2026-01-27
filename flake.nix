{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";

    flox = {
      url = "github:flox/flox/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      agenix,
      flox,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;

      commonSpecialArgs = {
        inherit inputs;
        network = import ../config/network.nix;
      };

    in
    {
      nixosConfigurations = {
        desktop = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = commonSpecialArgs;
          modules = [
            ./hosts/desktop

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.connor = ./modules/home-manager/default.nix;
              home-manager.backupFileExtension = "backup";
            }

            (
              { config, ... }:
              {
                home-manager.extraSpecialArgs = {
                  inherit inputs;

                  # Make the config available to home-manager
                  systemOptions = config;
                };
              }
            )

            agenix.nixosModules.default
          ];
        };

        laptop = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = commonSpecialArgs;
          modules = [
            ./hosts/laptop

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.connor = ./modules/home-manager/default.nix;
              home-manager.backupFileExtension = "backup";
            }

            # Make the config available to home-manager
            (
              { config, ... }:
              {
                home-manager.extraSpecialArgs = {
                  inherit inputs;

                  # Make the config available to home-manager
                  systemOptions = config;
                };
              }
            )

            agenix.nixosModules.default
          ];
        };

        server = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = commonSpecialArgs;
          modules = [
            ./hosts/server

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.connor = ./modules/home-manager/default.nix;
              home-manager.backupFileExtension = "backup";
            }

            (
              { config, ... }:
              {
                home-manager.extraSpecialArgs = {
                  inherit inputs;

                  # Make the config available to home-manager
                  systemOptions = config;
                };
              }
            )

            agenix.nixosModules.default
          ];
        };
      };
    };
}
