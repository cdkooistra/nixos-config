{ config, lib, ... }:

{
  options.nixos.networking = {
    hostName = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The hostname for this system.";
    };

    wireless.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable wireless";
    };
  };

  config = {
    networking = {
      hostName = config.nixos.networking.hostName;
      networkmanager.enable = true;

    } // lib.mkIf config.nixos.networking.wireless.enable {
      wireless.enable = true;
      # TODO: other wireless settings?
    };

  };
}