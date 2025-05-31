{ lib, config, pkgs, ... }:

{
    options = {
        gnome.enable
            = lib.mkEnableOption "enable GNOME";
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

        environment.gnome.excludePackages = with pkgs.gnome; [
            pkgs.gnome-contacts
            pkgs.gnome-text-editor
            pkgs.gnome-tour
            pkgs.gnome-maps
            pkgs.gnome-weather
            pkgs.geary
            pkgs.epiphany
        ];
    };
}
