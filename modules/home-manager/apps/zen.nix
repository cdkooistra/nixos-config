{ config, lib, ... }:

let
  cfg = config.apps.zen;
in
{
  options.apps.zen.enable = lib.mkEnableOption "Zen";

  config = lib.mkIf cfg.enable {
    services.flatpak.packages = [ "app.zen_browser.zen" ];
  };
}
