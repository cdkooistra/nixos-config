{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:

let
  cfg = config.gui.de.dux;
in
{
  # flake inputs
  imports = [
    inputs.dux-plugin-registry.nixosModules.default
  ];

  options.gui.de.dux = {
    enable = lib.mkEnableOption "dux Desktop Environment";
    compositor = lib.mkOption {
      type = lib.types.enum [ "niri" ]; # could also be hyprland/sway
      default = "niri";
      description = "compositor dux runs on";
    };
  };

  config = lib.mkIf cfg.enable {
    # dux pulls its compositor in; a host can still set it to false explicitly
    gui.compositor.${cfg.compositor}.enable = lib.mkDefault true;

    services = {
      # greetd greeter
      displayManager.dux-greeter = {
        enable = true;
        compositor.name = cfg.compositor;
      };

      # battery and power info for the shell
      upower.enable = true;

      # drives and network locations in the file manager
      udisks2.enable = true;
      gvfs.enable = true;

      power-profiles-daemon.enable = config.networking.hostName == "artemis";
    };

    # bluez daemon for the shell's bluetooth widget
    hardware.bluetooth.enable = config.networking.hostName == "artemis";

    environment.systemPackages = with pkgs; [
      qt6.qtimageformats
      kdePackages.kimageformats
      cups-pk-helper
      adw-gtk3
      papirus-icon-theme
    ];

    programs = {
      # the Wayland desktop shell
      dux-shell = {
        enable = true;

        # systemd service configuration
        systemd = {
          enable = true;
          restartIfChanged = true; # auto-restart dux.service when dux-shell changes
        };

        # plugins from inputs.dux-plugin-registry!!
        # plugin ids can be found from the dux store:
        # dms://plugin/install/dankBatteryAlerts -> dankBatteryAlerts
        # plugins = { };
      };
      dux-search = {
        enable = true;

        # systemd service configuration
        systemd = {
          enable = true;
          target = "graphical-session.target"; # start only with user GUI sessions
        };
      };
      dux-files = {
        enable = true;

        systemd = {
          enable = true;
          target = "graphical-session.target";
          restartIfChanged = true;
        };
        # Serve other apps' open and save dialogs
        portal.enable = true; # register the dfiles backend with xdg-desktop-portal
      };
    };

    # prefer dfiles for file choosers under niri
    xdg.portal.config.niri."org.freedesktop.impl.portal.FileChooser" = [ "dfiles" ];
  };
}
