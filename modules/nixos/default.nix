{
  imports = [ 
    ./locale.nix
    ./sops.nix 
  ];
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

}
