{ config, lib, pkgs, ... }:

{
  options.graphics = {
    displaylink.enable = lib.mkEnableOption "enable DisplayLink drivers";
  };

  config = lib.mkIf config.graphics.displaylink.enable {
    # apparently Displaylink for Wayland needs evdi module set like this
    boot = {
      extraModulePackages = [ config.boot.kernelPackages.evdi ];
      initrd = {
        # kernel modules that are always loaded by initrd
        kernelModules = [
          "evdi"
        ];
      };
    };

    environment.systemPackages = with pkgs; [
      displaylink
    ];
    
    services.xserver.videoDrivers = ["displaylink" ];

    systemd.services.dlm.wantedBy = [ "multi-user.target" ];

  };
}
