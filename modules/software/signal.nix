{ config, lib, pkgs, ... }:

{
  options.software = {
    signal.enable = lib.mkEnableOption "enable Signal";
  };

  config = lib.mkIf config.software.signal.enable {
    environment.systemPackages = [
      pkgs.signal-desktop
    ];
  };

}
