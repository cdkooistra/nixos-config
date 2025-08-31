{ config, lib, ... }:

{
  options.nixos.networking = {
    wireless.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable wireless";
    };
  };

  config = {
    networking = {
      networkmanager.enable = true;
      enableIPv6 = false;
      nameservers = [
        "86.54.11.13" # dns4eu
      ];
      # Conditionally enable wireless if the option is set
      wireless.enable = config.nixos.networking.wireless.enable;
    };
  };
}
