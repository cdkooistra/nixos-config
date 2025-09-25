{
  imports = [ 
    ./locale.nix
    ./sops.nix 
    ./networking.nix
    ./user.nix
    ./appimage.nix
    ./ssh.nix
  ];
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

}
