{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.graphics.nvidia = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable nvidia drivers";
    };
  };

  config = lib.mkIf config.graphics.nvidia.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;

      powerManagement = {
        enable = false; # known to cause timeouts
        finegrained = false;
      };

      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    environment = {
      systemPackages = with pkgs; [
        nvidia-vaapi-driver
      ];

      sessionVariables = {
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        # Required to run the correct GBM backend for nvidia GPUs on wayland
        GBM_BACKEND = "nvidia-drm";
        # Hardware cursors are currently broken on wlroots
        WLR_NO_HARDWARE_CURSORS = "1";
      };
    };

    boot = {
      kernelModules = [
        "nvidia"
        "nvidiafb"
        "nvidia_drm"
        "nvidia_uvm"
        "nvidia_modeset"
      ];

      kernelParams = [
        # Enable DRM kernel mode setting (important for Wayland)
        "nvidia-drm.modeset=1"
        # Help prevent sleep/wake issues
        "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      ];

      # Load modules early in boot process
      initrd.kernelModules = [
        "nvidia"
        "nvidia_drm"
      ];
    };
  };
}
