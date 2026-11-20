{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:

let
  cfg = config.desktops.dux;
in
{
  # flake inputs
  imports = [
    inputs.dux-plugin-registry.nixosModules.default
  ];

  options.desktops.dux = {
    enable = lib.mkEnableOption "dux Desktop Environment";
  };

  config = lib.mkIf cfg.enable {
    services = {
      # greetd greeter
      displayManager.dux-greeter = {
        enable = true;
        compositor.name = "niri"; # Or "hyprland" or "sway"
      };

      # battery and power info for the shell
      upower.enable = true;
    };

    environment.systemPackages = with pkgs; [
      qt6.qtimageformats
      kdePackages.kimageformats
      power-profiles-daemon # for artemis only
      cups-pk-helper
      adw-gtk3
    ];

    programs = {
      # compositor used by the greeter
      niri.enable = true;

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
