{
  lib,
  config,
  ...
}:

let
  cfg = config.desktops.cosmic;
  wayland = config.graphics.wayland;
in
{
  options.desktops.cosmic = {
    enable = lib.mkEnableOption "COSMIC Desktop Environment";
  };

  config = lib.mkIf cfg.enable {
    services = {
      # COSMIC login manager
      displayManager.cosmic-greeter.enable = true;

      # COSMIC environment
      desktopManager.cosmic = {
        enable = true;
        xwayland.enable = wayland.xwayland.enable;
      };

      system76-scheduler.enable = true;
    };
  };
}
