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
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:     
    let
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        desktop = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit inputs;};
          modules = [
            ./hosts/desktop

            home-manager.nixosModules.home-manager 
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.users.connor = ./home.nix;
            }
          ];
        };
      };
    };
}
