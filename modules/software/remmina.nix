{ config, lib, pkgs, ... }:

{
  options.software = {
    remmina.enable = lib.mkEnableOption "enable Remmina RDP";
  };

  config = lib.mkIf config.software.remmina.enable {
    environment.systemPackages = [
      pkgs.remmina
    ];
  };

}
