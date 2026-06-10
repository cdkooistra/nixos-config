#
# Sisyphus, condemned to roll a boulder uphill for eternity, my main workstation where the grind never stops.
#
{
  mkHost,
  network,
  lib,
  secretsDir,
  ...
}:

mkHost {
  name = "sisyphus";
  arch = "x86_64-linux";

  system = {
    age.identityPaths = [
      "/home/connor/.ssh/id_ed25519"
    ];

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
      devenv.enable = true;
      espanso.enable = false;
      rsync.enable = true;

      tailscale = {
        enable = true;
        ssh = true;

        auth = {
          enable = true;
          file = "${secretsDir}/tailscale.age";
          params = {
            preauthorized = true;
            ephemeral = false;
          };
        };

        serve = {
          enable = true;
          services = {
            # set up some basic server using: python3 -m http.server 8080
            example-web-server = {
              endpoints = {
                # service endpoint with port 443 linked to local endpoint with port 8080
                "tcp:443" = "http://localhost:8080";
              };
              advertised = true; # this is the default case, understand now, remove later
            };
          };
        };

        tags = [ "tag:workstation" ];
      };

      syncthing = {
        enable = true;
        deviceId = network.devices.sisyphus;
        peers = lib.removeAttrs network.devices [ "sisyphus" ];
      };
    };

    services = {
      browsers = {
        enable = true;

        instances = {
          idleon = {
            dir = "/srv/browsers/idleon";
            secretFile = "${secretsDir}/browsers-idleon.age";
            port = 5800;
          };
        };
      };
    };

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

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      extraConfig.pipewire = {
        "99-gaming-latency" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.allowed-rates" = [
              44100
              48000
            ];
            # Door min en max gelijk te zetten, kan Proton de buffer niet meer verlagen naar 256
            "default.clock.quantum" = 512;
            "default.clock.min-quantum" = 512;
            "default.clock.max-quantum" = 512;
            "stream.properties" = {
              "resample.quality" = 4; # Verlaagt de CPU overhead voor resampling
            };
          };
        };
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
