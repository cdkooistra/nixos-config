{ config, lib, pkgs, ... }:

{ 
  options.nixos.ssh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable SSH";
    };
    
  };

  config = lib.mkIf config.nixos.ssh.enable {
    services.openssh = {
      enable = true;
      openFirewall = false;

      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
      };
    };
  };

}
