{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.desktops.gnome;
  wayland = config.graphics.wayland;
in
{
  options.desktops.gnome = {
    enable = lib.mkEnableOption "GNOME Desktop Environment";

    mode = lib.mkOption {
      type = lib.types.enum [
        "client"
        "server"
      ];
      default = "client";
      description = "what mode to use, e.g.: client or server";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services = {
          desktopManager.gnome.enable = true;

          displayManager = {
            gdm = {
              enable = true;
              wayland = wayland.enable;
            };
          }
          // lib.optionalAttrs (cfg.mode == "server") {
            autoLogin = {
              enable = true;
              user = "connor";
            };
          };
        };

        environment = {
          systemPackages =
            let
              gnomePkgs = with pkgs; [
                gnome-tweaks
                dconf2nix
                papirus-icon-theme
              ];
              gnomeExts =
                with pkgs.gnomeExtensions;
                lib.flatten [
                  pop-shell
                  dash-to-panel
                  appindicator
                  vitals
                  wallpaper-slideshow

                  (lib.optional config.software.tailscale.enable tailscale-status)
                  (lib.optional (config.networking.hostName == "artemis") battery-health-charging)
                ];
            in
            gnomePkgs ++ gnomeExts;

          gnome.excludePackages =
            with pkgs;
            lib.flatten [
              gnome-contacts
              gnome-text-editor
              gnome-tour
              gnome-maps
              gnome-weather
              gnome-clocks
              gnome-characters
              gnome-user-docs
              geary
              epiphany
              gedit
              evince
              yelp

              (lib.optional (config.networking.hostName != "artemis") gnome-bluetooth)
            ];
        };
      }
    ]
  );
}
