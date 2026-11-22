{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.gui.compositor.niri;
  wayland = config.graphics.wayland;
in
{
  options.gui.compositor.niri = {
    enable = lib.mkEnableOption "niri compositor";
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    environment.systemPackages = lib.optional wayland.xwayland.enable pkgs.xwayland-satellite;
  };
}
