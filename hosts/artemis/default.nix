#
# Artemis, goddess of the hunt, thin and mobile workstation for productivity and development.
#

{
  mkHost,
  network,
  secretsDir,
  ...
}:

mkHost {
  name = "artemis";
  arch = "x86_64-linux";

  system = {
    age.identityPaths = [
      "/home/connor/.ssh/id_ed25519"
    ];

    graphics = {
      amd.enable = true;
      displaylink.enable = true;
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
      devenv.enable = true;
      tailscale = {
        enable = true;

        auth = {
          enable = true;
          file = "${secretsDir}/tailscale.age";
          params = {
            preauthorized = true;
            ephemeral = false;
          };
        };
        tags = [ "tag:laptop" ];

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
      syncthing = {
        enable = true;
        deviceId = network.devices.artemis;
        peers.sisyphus = network.devices.sisyphus;
      };

    };

    boot.loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 4;
      };
      efi.canTouchEfiVariables = true;
      timeout = 4;
    };

    swapDevices = [
      {
        device = "/swapfile";
        size = 8 * 1024;
        options = [ "discard" ];
      }
    ];

    security = {
      rtkit.enable = true;
    };

    services.pulseaudio.enable = false;
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
    apps = {
      discord.enable = true;
      obsidian.enable = true;
      onlyoffice.enable = true;
      proton.enable = true;
      slack.enable = true;
      signal.enable = true;
      spotify.enable = true;
      zen.enable = true;
    };
  };
}
