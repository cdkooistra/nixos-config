{ config, lib, pkgs, ... }:

{
  options = {
    nvidia.enable = lib.mkEnableOption "enable nvidia drivers";
  };
  
  config = lib.mkIf config.nvidia.enable {
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
