{ mkHost, network, ... }:

mkHost {
  name = "artemis";
  arch = "x86_64-linux";

  system = {
    graphics = {
      amd.enable = true;
      displaylink.enable = true;
      wayland.enable = true;
      wayland.xwayland.enable = true;
    };

    desktops.gnome = {
      enable = true;
      mode = "client";
    };

    software = {
      docker.enable = true;
      devenv.enable = true;
      espanso.enable = true;
      tailscale.enable = true;
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

    services.xserver.xkb = {
      layout = "us";
      variant = "alt-intl";
    };

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
      proton.enable = true;
      slack.enable = true;
      signal.enable = true;
      spotify.enable = true;
      zen.enable = true;
    };
    # desktop = "gnome";
  };
}
