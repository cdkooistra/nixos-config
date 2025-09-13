{ config, lib, pkgs, ... }:

{
  options.software.rustdesk = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable Rustdesk";
    };

    type = lib.mkOption {
      type = lib.types.enum [ "client" "server" ];
      default = "client";
      description = "Rustdesk deployment type: client or server";
    };

  };

  config = lib.mkIf config.software.rustdesk.enable {
    
    # environment.systemPackages = 
    #   lib.mkIf (config.software.rustdesk.type == "client") (with pkgs; [
    #     rustdesk
    #   ]);
    environment.systemPackages = with pkgs; [
      rustdesk
    ];
    
  };


}