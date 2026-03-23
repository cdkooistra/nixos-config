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
