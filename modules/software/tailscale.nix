{ config, lib, pkgs, ... }:

{ 
  options.software.tailscale = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable Tailscale";
    };
  };

  config = lib.mkIf config.software.tailscale.enable {
    services.tailscale = {
      enable = true;
    };

  };
}
