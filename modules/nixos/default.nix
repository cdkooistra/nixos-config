{
  imports = [ 
    ./locale.nix
    ./sops.nix 
    ./networking.nix
    ./user.nix
  ];
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

}
