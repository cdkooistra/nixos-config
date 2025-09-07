{ config, lib, pkgs, ... }:

{
  options.software.signal = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable Signal"; 
    }; 
  };

  config = lib.mkIf config.software.signal.enable {
    environment.systemPackages = [
      pkgs.signal-desktop
    ];
  };

}
