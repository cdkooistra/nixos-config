{ inputs, pkgs, ... }:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  environment.systemPackages = with pkgs; [
    sops
    age
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/connor/.config/sops/age/keys.txt";

    # secrets."syncthing-pw" = {
    #   owner = "connor";
    # };

  };


}