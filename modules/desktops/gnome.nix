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
    };
}
