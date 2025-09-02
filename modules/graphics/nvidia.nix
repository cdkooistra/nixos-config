{ config, lib, pkgs, ... }:

{
  options.graphics = {
    nvidia.enable = lib.mkEnableOption "enable nvidia drivers";
  };
  
  config = lib.mkIf config.graphics.nvidia.enable {
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      
      powerManagement = {
        enable = false;
        finegrained = false;
      };

      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
