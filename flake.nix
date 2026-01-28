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

      mkHost =
        {
          name,
          arch,
          modules,
          extraSpecialArgs ? { },
        }:
        lib.nixosSystem {
          system = arch;
          # common specialArgs for each system
          specialArgs = lib.recursiveUpdate {
            inherit inputs;

            # imports
            network = import ../config/network.nix;

            # vars
            hostName = name;
          } extraSpecialArgs;
          inherit modules;
        };
    in
    {
      nixosConfigurations = {
        sisyphus = mkHost {
          name = "sisyphus";
          arch = "x86_64-linux";
          modules = [
            ./hosts/sisyphus

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.connor = ./modules/home-manager/default.nix;
              home-manager.backupFileExtension = "backup";
            }
            (
              { config, hostName, ... }:
              {
                home-manager.extraSpecialArgs = {
                  inherit inputs hostName;

                  # Make the config available to home-manager
                  systemOptions = config;
                };
              }
            )
            agenix.nixosModules.default
          ];
          # extraSpecialArgs = {};
        };

        artemis = mkHost {
          name = "artemis";
          arch = "x86_64-linux";
          modules = [
            ./hosts/artemis

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.connor = ./modules/home-manager/default.nix;
              home-manager.backupFileExtension = "backup";
            }
            (
              { config, hostName, ... }:
              {
                home-manager.extraSpecialArgs = {
                  inherit inputs hostName;

                  # Make the config available to home-manager
                  systemOptions = config;
                };
              }
            )
            agenix.nixosModules.default
          ];
        };

        hermes = mkHost {
          name = "hermes";
          arch = "x86_64-linux";
          modules = [
            ./hosts/hermes

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.connor = ./modules/home-manager/default.nix;
              home-manager.backupFileExtension = "backup";
            }
            (
              { config, hostName, ... }:
              {
                home-manager.extraSpecialArgs = {
                  inherit inputs hostName;

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
