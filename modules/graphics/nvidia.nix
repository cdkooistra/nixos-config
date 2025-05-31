{ config, pkgs, ... }:

{
    # enable OpenGL
    hardware.graphics = {
        enable = true;
        enable32Bit = true; # 32bit compatibility
    };

    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
}
