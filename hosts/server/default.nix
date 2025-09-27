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
    
  # nixos
  networking.hostName = "hermes";

  graphics.amd.enable = true;
  
  gnome = {
    enable = true;
    mode = "server";
  };
  
  software = {
    docker.enable = true;

    tailscale = {
      enable = true;
      ssh = true;
    };

    # TODO:
    # how should hermes be peered with other systems? 
    # syncthing = {
    #   enable = false;
    #   deviceId = devices.hermes;
    # };

      #deviceId = devices.hermes;
      
      # TODO:
      # how should hermes be peered with other systems? 
  };

  # Disable systemd targets for sleep and hibernation
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.enableAllFirmware = lib.mkDefault true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
