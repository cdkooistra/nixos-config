{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.graphics.wayland;
in
{
  options.graphics.wayland = {
    enable = lib.mkEnableOption "Wayland Compositor";
    xwayland.enable = lib.mkEnableOption "XWayland compatibilty layer";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = cfg.xwayland.enable;

    environment = {
      systemPackages = with pkgs; [
        wayland
        wayland-protocols
        wayland-utils
        wl-clipboard

        libdecor
        gtk3
        cairo

        # TODO: is this the right place for these?
        vulkan-loader
        vulkan-tools
        vulkan-validation-layers
      ];

      sessionVariables = {
        GDK_BACKEND = "wayland";
      };
    };
  };
}
