{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.apps.espanso;
in
{
  options.apps.espanso.enable = lib.mkEnableOption "espanso";

  config = lib.mkIf cfg.enable {
    services.espanso = {
      enable = true;
      waylandSupport = true;

      package = pkgs.espanso-wayland;

      configs = {
        default = {
          show_notifications = false;
          keyboard_layout = {
            layout = "us";
            variant = "intl";
          };
        };
      };
    };
  };
}
