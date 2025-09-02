{ lib, config, pkgs, ... }:

{
  options = {
    gnome.enable = lib.mkEnableOption "enable GNOME";
  };
  
  config = lib.mkIf config.gnome.enable {
      # Enables GDM (Wayland) and GNOME system.
    services.xserver = {
      enable = true;
  
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
  
      desktopManager.gnome.enable = true;
    };

    environment.systemPackages = with pkgs; [
      gnome-tweaks
      dconf2nix
      gnomeExtensions.dash-to-panel
      gnomeExtensions.pop-shell
      papirus-icon-theme
    ];

    environment.gnome.excludePackages = with pkgs; [
      pkgs.gnome-contacts
      pkgs.gnome-text-editor
      pkgs.gnome-tour
      pkgs.gnome-maps
      pkgs.gnome-weather
      pkgs.gnome-clocks
      pkgs.gnome-characters
      pkgs.gnome-connections
      pkgs.gnome-bluetooth # TODO: if desktop -> disable bt | else -> enable bt
      pkgs.gnome-user-docs
      pkgs.geary
      pkgs.epiphany
      pkgs.gedit
      evince
      yelp
    ];
  };
}
