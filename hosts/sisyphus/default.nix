#
# Sisyphus, condemned to roll a boulder uphill for eternity, my main workstation where the grind never stops.
#
{
  mkHost,
  network,
  lib,
  secrets,
  pkgs,
  ...
}:

mkHost {
  name = "sisyphus";
  arch = "x86_64-linux";

  system = {
    age = {
      identityPaths = [
        "/home/connor/.ssh/id_ed25519"
      ];
      secrets.passwd.file = "${secrets}/passwd.age";
    };

    graphics = {
      nvidia.enable = true;
      wayland = {
        enable = true;
        xwayland.enable = true;
      };
    };

    desktops.gnome = {
      enable = true;
      mode = "client";
    };

    software = {
      docker.enable = true;
      espanso.enable = true;
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

    services = {
      browsers = {
        enable = false;

        instances = {
          idleon = {
            dir = "/srv/browsers/idleon";
            secretFile = "${secrets}/browsers-idleon.age";
            port = 5800;
          };
        };
      };
    };

    # keychron support
    services.udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="1610", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
    '';

    gaming = {
      utils = {
        gamescope.enable = false;
        gamemode.enable = true;
        mangohud.enable = true;
        protonup.enable = true;
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

    system = {
      dev.enable = true;
      openssh = {
        enable = true;
        allowTailscale = true;
      };
      appformats = {
        appimage = {
          enable = true;
          extraPkgs = with pkgs; [ icu ];
        };
        flatpak.enable = true;
      };
    };

    fileSystems = {
      "/run/media/connor/Games" = {
        device = "/dev/disk/by-uuid/31b1a084-e5ab-4c46-b129-c8b4c51049d9";
        fsType = "btrfs";
      };
      "/run/media/connor/Storage" = {
        device = "/dev/disk/by-uuid/8222BD7522BD6F33";
        fsType = "ntfs";
      };
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

    # for USB audio interfaces
    boot.kernelParams = [
      "preempt=full"
      "usbcore.autosuspend=-1"
    ];
    # boot.extraModprobeConfig = "options snd-hda-intel enable_msi=1";

    system.stateVersion = "25.05";
  };

  user = {
    apps = {
      discord.enable = true;
      espanso.enable = false;
      obsidian.enable = true;
      onlyoffice.enable = true;
      pinta.enable = true;
      proton.enable = true;
      signal.enable = true;
      spotify.enable = true;
      zen.enable = true;
    };
  };
}
