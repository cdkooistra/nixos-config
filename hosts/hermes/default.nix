#
# Hermes, the messenger of the gods, manages primarily services to use across my network.
#

{
  mkHost,
  network,
  secrets,
  ...
}:

mkHost {
  name = "hermes";
  arch = "x86_64-linux";

  system = {
    age = {
      identityPaths = [
        "/home/connor/.ssh/id_ed25519"
      ];
      secrets.passwd.file = "${secrets}/passwd.age";
    };

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

        auth = {
          enable = true;
          file = "${secrets}/tailscale.age";
          params = {
            preauthorized = true;
            ephemeral = false;
          };
          tags = [ "tag:server" ];
        };

        serve = {
          enable = false;
          # services = {
          #   # set up some basic server using: python3 -m http.server 8080
          #   example-web-server = {
          #     endpoints = {
          #       # service endpoint with port 443 linked to local endpoint with port 8080
          #       "tcp:443" = "http://localhost:8080";
          #     };
          #     advertised = true; # this is the default case, understand now, remove later
          #   };
          # };
        };
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
        version = "0.13.0";
        dir = "/srv/solidtime";
        port = 8000;
        secretFile = "${secrets}/solidtime.age";

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
        secretFile = "${secrets}/immich.age";

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
        secretFile = "${secrets}/stirling.age";

        tailscale = {
          enable = true;
          hostname = "pdf";
          tailnet = network.tailnet;
          serve = {
            "/" = "http://172.17.0.1:8080";
          };
        };
      };

      forgejo-service = {
        enable = true;
        port = 8090;
        dir = "/srv/forgejo";
        secretFile = "${secrets}/forgejo.age";

        tailscale = {
          enable = true;
          hostname = "git";
          tailnet = network.tailnet;
          serve = {
            "/" = "http://172.17.0.1:8090";
          };
        };
      };

      browsers = {
        enable = false;

        instances = {
          idleon = {
            dir = "/srv/browsers/idleon";
            secretFile = "${secrets}/browsers-idleon.age";

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

    system = {
      openssh = {
        enable = true;
        allowTailscale = true;
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
}
