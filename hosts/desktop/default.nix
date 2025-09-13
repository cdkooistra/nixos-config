# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, devices, lib, pkgs, ... }:

let 
  modules = import ../../modules;
in 
{
  imports =
    [
      ./hardware-configuration.nix
      modules.nixos
      modules.graphics
      modules.desktops.gnome
      modules.software
    ];

  # device name
  networking.hostName = "sisyphus";
  
  gnome.enable = true;
  graphics.nvidia.enable = true;
  
  software = {
    proton.enable = true;
    onlyoffice.enable = true;
    signal.enable = true;
    pinta.enable = true;
    docker.enable = true;
    
    rustdesk.enable = true;

    tailscale = {
      enable = true;
    };

    syncthing = {
      enable = true;
      deviceId = devices.sisyphus;

      # automatically include all devices as peers except self
      peers = lib.removeAttrs devices [ config.networking.hostName ];
    };

    # gaming related
    steam.enable = true;
    xone.enable = true;
    prism.enable = true;
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
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
