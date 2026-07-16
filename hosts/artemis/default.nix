#
# Artemis, goddess of the hunt, thin and mobile workstation for productivity and development.
#

{
  mkHost,
  network,
  secrets,
  ...
}:

mkHost {
  name = "artemis";
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
      tailscale.enable = true;
      syncthing = {
        enable = true;
        deviceId = network.devices.artemis;
        peers.sisyphus = network.devices.sisyphus;
      };
    };

    system = {
      dev.enable = true;
      appformats = {
        appimage.enable = true;
        flatpak.enable = true;
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
      signal.enable = true;
      spotify.enable = true;
      zen.enable = true;
    };
  };
}
