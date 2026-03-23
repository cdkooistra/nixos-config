{
  mkHost,
  network,
  secretsDir,
  ...
}:

mkHost {
  name = "hermes";
  arch = "x86_64-linux";

  system = {
    age.identityPaths = [
      "/home/connor/.ssh/id_ed25519"
    ];

    graphics = {
      amd.enable = true;
      wayland.enable = true;
      wayland.xwayland.enable = true;
    };

    desktops.gnome = {
      enable = true;
      mode = "server";
    };

    software = {
      docker.enable = true;
      tailscale = {
        enable = true;
        ssh = true;
      };
      rsync = {
        enable = true;
        backups.immich-data = {
          src = "/mnt/data/immich";
          dst = "connor@sisyphus:/run/media/connor/Storage/immich-backup";
          schedule = "12:00";
        };
      };
    };

    services = {
      solidtime = {
        enable = true;
        version = "0.11.6";
        dir = "/srv/solidtime";
        port = 8000;
        secretFile = "${secretsDir}/solidtime.age";

        tailscale = {
          enable = true;
          hostname = "solidtime";
          tailnet = network.tailnet;
          serve = {
            "/" = "http://127.0.0.1:8000";
          };
        };
      };

      immich-service = {
        enable = true;
        dir = "/srv/immich";
        dataDir = "/mnt/data/immich";
        secretFile = "${secretsDir}/immich.age";

        tailscale = {
          enable = true;
          hostname = "immich";
          tailnet = network.tailnet;
          serve = {
            "/" = "http://172.17.0.1:2283";
          };
        };
      };

      stirling = {
        enable = true;
        dir = "/srv/stirling";
        secretFile = "${secretsDir}/stirling.age";

        tailscale = {
          enable = true;
          hostname = "pdf";
          tailnet = network.tailnet;
          serve = {
            "/" = "http://172.17.0.1:8080";
          };
        };
      };

      browsers = {
        enable = false;

        instances = {
          idleon = {
            dir = "/srv/browsers/idleon";
            secretFile = "${secretsDir}/browsers-idleon.age";

            tailscale = {
              enable = true;
              hostname = "idleon";
              tailnet = network.tailnet;
              serve = {
                "/" = "http://127.0.0.1:3000";
              };
              magicdns = false;
            };
          };
        };
      };
    };

    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    hardware.enableAllFirmware = true;

    system.stateVersion = "25.05";
  };

  user = {
    # desktop = "gnome";
  };
}
