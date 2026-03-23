{
  mkHost,
  network,
  lib,
  ...
}:

mkHost {
  name = "sisyphus";
  arch = "x86_64-linux";

  system = {
    graphics = {
      nvidia.enable = true;
      wayland.enable = true;
      wayland.xwayland.enable = true;
    };

    desktops.gnome = {
      enable = true;
      mode = "client";
    };

    software = {
      proton.enable = true;
      onlyoffice.enable = true;
      signal.enable = true;
      pinta.enable = true;
      docker.enable = true;
      flox.enable = true;
      devenv.enable = true;
      espanso.enable = false;
      rsync.enable = true;
      tailscale = {
        enable = true;
        ssh = true;
      };
      syncthing = {
        enable = true;
        deviceId = network.devices.sisyphus;
        peers = lib.removeAttrs network.devices [ "sisyphus" ];
      };
    };

    gaming = {
      utils = {
        gamescope.enable = false;
        gamemode.enable = true;
        mangohud.enable = true;
      };
      launchers = {
        steam.enable = true;
        prism.enable = true;
        bottles.enable = true;
      };
      controllers = {
        xone.enable = true;
      };
    };

    fileSystems."/run/media/connor/Games" = {
      device = "/dev/disk/by-uuid/31b1a084-e5ab-4c46-b129-c8b4c51049d9";
      fsType = "btrfs";
    };

    fileSystems."/run/media/connor/Storage" = {
      device = "/dev/disk/by-uuid/8222BD7522BD6F33";
      fsType = "ntfs";
    };

    boot = {
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 4;
          windows."11-home" = {
            title = "Windows 11";
            efiDeviceHandle = "HD3a65535a1";
            sortKey = "z_windows";
          };
          consoleMode = "auto";
        };
        efi.canTouchEfiVariables = true;
        timeout = 10;
      };
    };

    services.xserver.xkb = {
      layout = "us";
      variant = "alt-intl";
    };

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    system.stateVersion = "25.05";
  };

  user = {
    desktop = "gnome";
  };
}
