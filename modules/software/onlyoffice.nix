{ config, lib, pkgs, ... }:

{
  options.software = {
    onlyoffice.enable = lib.mkEnableOption "enable Onlyoffice";
  };

  config = lib.mkIf config.software.onlyoffice.enable {
    environment.systemPackages = [
      pkgs.onlyoffice-bin
    ];
  };

}
