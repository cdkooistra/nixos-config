# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  # devices,
  config,
  inputs,
  lib,
  ...
}:

let
  tailnet = "tail0e2331";
  modules = import ../../modules;
in
{
  imports = [
    ./hardware-configuration.nix
    modules.nixos
    modules.graphics
    modules.desktops.gnome
    modules.software
    modules.services
  ];

  # age
  age.identityPaths = [
    "${config.users.users.connor.home}/.ssh/id_ed25519"
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

    rsync = {
      enable = true;
      backups = {
        immich-data = {
          src = "/mnt/data/immich";
          dst = "connor@sisyphus:/run/media/connor/Storage/immich-backup";
          schedule = "12:00";
        };
      };
    };

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

  services = {
    solidtime = {
      enable = true;
      directory = "/srv/solidtime";
      port = 8000;
      # inputs.self = flake input reference
      # so this means abs path from flake root
      secretFile = inputs.self + "/secrets/solidtime.age";

      tailscale = {
        enable = true;
        hostname = "solidtime";
        tailnet = tailnet;
        envfile = "solidtime";
        serve = {
          "/" = "http://127.0.0.1:8000";
        };
        magicdns = true; # default = true, so can omit
      };
    };

    immich-container = {
      enable = true;
      dir = "/srv/immich";
      dataDir = "/mnt/data/immich";
      secretFile = inputs.self + "/secrets/immich.age";

      tailscale = {
        enable = true;
        hostname = "immich";
        tailnet = tailnet;
        # envfile = "immich";
        serve = {
          "/" = "http://127.0.0.1:2283";
        };
      };
    };
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
