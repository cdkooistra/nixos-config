{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.desktops.gnome;
in
{
  options.desktops.gnome = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable GNOME";
    };

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
          xserver.enable = true;
          desktopManager.gnome.enable = true;

          displayManager = {
            gdm = {
              enable = true;
              wayland = true;
            };
          }
          // lib.optionalAttrs (cfg.mode == "server") {
            autoLogin = {
              enable = true;
              user = "connor";
            };
          };
        };

        environment.systemPackages =
          let
            gnomePkgs = with pkgs; [
              gnome-tweaks
              dconf2nix
              papirus-icon-theme
            ];

            gnomeExts =
              with pkgs.gnomeExtensions;
              [
                pop-shell
                dash-to-panel
                appindicator
                vitals
                wallpaper-slideshow
              ]
              ++ lib.optionals (config.software.tailscale.enable) [ tailscale-status ]
              ++ lib.optionals (config.networking.hostName == "artemis") [ battery-health-charging ];
          in
          gnomePkgs ++ gnomeExts;

        environment.gnome.excludePackages =
          with pkgs;
          [
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
          ]
          ++ lib.optionals (config.networking.hostName != "artemis") [ gnome-bluetooth ];
      }
    ]
  );
}
