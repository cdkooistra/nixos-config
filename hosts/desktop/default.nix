{
  config,
  devices,
  lib,
  ...
}:

let
  modules = import ../../modules/nixos;
in
{
  imports = [
    ./hardware-configuration.nix
    modules.system
    modules.graphics
    modules.desktops
    modules.software
    modules.gaming
  ];

  # device name
  networking.hostName = "sisyphus";

  graphics.nvidia.enable = true;

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
    espanso.enable = true;

    # to receive from hermes
    rsync.enable = true;

    tailscale = {
      enable = true;
      ssh = true;
    };

    syncthing = {
      enable = true;
      deviceId = devices.sisyphus;

      # automatically include all devices as peers except self
      peers = lib.removeAttrs devices [ config.networking.hostName ];
    };
  };

  gaming = {
    utils = {
      gamescope.enable = true;
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

  # enable auto mounting drives
  fileSystems."/run/media/connor/Games" = {
    device = "/dev/disk/by-uuid/31b1a084-e5ab-4c46-b129-c8b4c51049d9";
    fsType = "btrfs";
  };

  fileSystems."/run/media/connor/Storage" = {
    device = "/dev/disk/by-uuid/8222BD7522BD6F33";
    fsType = "ntfs";
  };

  # Bootloader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 4;
    };
    efi.canTouchEfiVariables = true;
    timeout = 10;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "alt-intl";
  };

  # Configure console keymap
  console.keyMap = "dvorak";

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
