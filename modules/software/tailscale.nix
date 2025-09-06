{ config, lib, pkgs, ... }:

{ 
  options.software.tailscale = {
    enable = lib.mkEnableOption "enable Tailscale";
  };

  config = lib.mkIf config.software.tailscale.enable {
    services.tailscale = {
      enable = true;
    };

  };
}
