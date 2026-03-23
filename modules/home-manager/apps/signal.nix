{ config, lib, ... }:
let
  cfg = config.apps.signal;
in
{
  options.apps.signal.enable = lib.mkEnableOption "Signal";

  config = lib.mkIf cfg.enable {
    services.flatpak.packages = [ "org.signal.Signal" ];
  };
}
