{ lib, config, pkgs, ... }:

{
  options.gnome = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable GNOME";
    };
  };
  
  config = lib.mkIf config.gnome.enable {
      # Enables GDM (Wayland) and GNOME system.

    services = {
      xserver.enable = true;
      
      desktopManager.gnome.enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    };

    environment.systemPackages = 
      let 
        gnomePkgs = with pkgs; [
          gnome-tweaks
          dconf2nix
          papirus-icon-theme
        ];

        gnomeExts = with pkgs.gnomeExtensions; [
          pop-shell
          dash-to-panel
          appindicator
          vitals
          wallpaper-slideshow
        ]
        ++ lib.optionals config.software.tailscale.enable [ tailscale-status ]
        ++ lib.optionals (config.networking.hostName == "artemis") [ battery-health-charging ];
      in
        gnomePkgs ++ gnomeExts;

    environment.gnome.excludePackages = with pkgs; [
      gnome-contacts
      gnome-text-editor
      gnome-tour
      gnome-maps
      gnome-weather
      gnome-clocks
      gnome-characters
      gnome-connections
      gnome-user-docs
      geary
      epiphany
      gedit
      evince
      yelp
    ]
    ++ lib.optionals (config.networking.hostName == "artemis") [ gnome-bluetooth ];
  };
}
