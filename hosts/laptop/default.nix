{
  devices,
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
  ];

  # device name
  networking.hostName = "artemis";

  graphics = {
    amd.enable = true;
    displaylink.enable = true;
  };

  desktops.gnome = {
    enable = true;
    mode = "client";
  };

  software = {
    proton.enable = true;
    onlyoffice.enable = true;
    signal.enable = true;
    docker.enable = true;
    flox.enable = true;
    espanso.enable = true;

    tailscale = {
      enable = true;
    };

    syncthing = {
      enable = true;
      deviceId = devices.artemis;

      peers = {
        sisyphus = devices.sisyphus;
      };
    };
  };

  # Bootloader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 4;
    };
    efi.canTouchEfiVariables = true;
    timeout = 4;
  };

  # Swapfile
  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
      options = [ "discard" ];
    }
  ];

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
