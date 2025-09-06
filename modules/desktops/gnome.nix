{ lib, config, pkgs, ... }:

{
  options.gnome = {
    enable = lib.mkEnableOption "enable GNOME";
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
        ]
        ++ lib.optionals config.software.tailscale.enable [ tailscale-status ];

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
    ++ lib.optionals (config.networking.hostName != "artemis") [ gnome-bluetooth ];
  };
}
