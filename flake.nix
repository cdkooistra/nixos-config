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
      modules = import ./modules/nixos;
      network = import ../config/network.nix;
      secretsDir = toString ./../secrets;

      mkHost =
        {
          name,
          arch,
          system ? { },
          user ? { },
          # modules,
          # extraSpecialArgs ? { },
        }:
        lib.nixosSystem {
          system = arch;
          # common specialArgs for each system
          specialArgs = {
            inherit inputs network;

            # vars
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
            system

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = null;
              home-manager.users.connor = ./modules/home-manager/default.nix;
              home-manager.extraSpecialArgs = {
                inherit inputs user;
                hostName = name;
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        # sisyphus = mkHost {
        #   name = "sisyphus";
        #   arch = "x86_64-linux";
        #   modules = [
        #     ./hosts/sisyphus

        #     home-manager.nixosModules.home-manager
        #     {
        #       home-manager.useGlobalPkgs = true;
        #       home-manager.useUserPackages = true;
        #       home-manager.users.connor = ./modules/home-manager/default.nix;
        #       home-manager.backupFileExtension = null;
        #     }
        #     (
        #       { config, hostName, ... }:
        #       {
        #         home-manager.extraSpecialArgs = {
        #           inherit inputs hostName;

        #           # Make the config available to home-manager
        #           systemOptions = config;
        #         };
        #       }
        #     )
        #     agenix.nixosModules.default
        #   ];
        #   # extraSpecialArgs = {};
        # };

        sisyphus = import ./hosts/sisyphus {
          inherit
            mkHost
            network
            inputs
            lib
            ;
        };
        artemis = import ./hosts/artemis { inherit mkHost network inputs; };
        hermes = import ./hosts/hermes {
          inherit
            mkHost
            network
            inputs
            secretsDir
            ;
        };
        # artemis = mkHost {
        #   name = "artemis";
        #   arch = "x86_64-linux";
        #   modules = [
        #     ./hosts/artemis

        #     home-manager.nixosModules.home-manager
        #     {
        #       home-manager.useGlobalPkgs = true;
        #       home-manager.useUserPackages = true;
        #       home-manager.users.connor = ./modules/home-manager/default.nix;
        #       home-manager.backupFileExtension = null;
        #     }
        #     (
        #       { config, hostName, ... }:
        #       {
        #         home-manager.extraSpecialArgs = {
        #           inherit inputs hostName;

        #           # Make the config available to home-manager
        #           systemOptions = config;
        #         };
        #       }
        #     )
        #     agenix.nixosModules.default
        #   ];
        # };

        # hermes = mkHost {
        #   name = "hermes";
        #   arch = "x86_64-linux";
        #   modules = [
        #     ./hosts/hermes

        #     home-manager.nixosModules.home-manager
        #     {
        #       home-manager.useGlobalPkgs = true;
        #       home-manager.useUserPackages = true;
        #       home-manager.users.connor = ./modules/home-manager/default.nix;
        #       home-manager.backupFileExtension = null;
        #     }
        #     (
        #       { config, hostName, ... }:
        #       {
        #         home-manager.extraSpecialArgs = {
        #           inherit inputs hostName;

        #           # Make the config available to home-manager
        #           systemOptions = config;
        #         };
        #       }
        #     )
        #     agenix.nixosModules.default
        #   ];
        # };
      };
    };
}
