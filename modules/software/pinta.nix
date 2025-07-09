{ config, lib, pkgs, ... }:

{
  options.software = {
    pinta.enable = lib.mkEnableOption "enable pinta";
  };

  config = lib.mkIf config.software.pinta.enable {
    environment.systemPackages = [
      pkgs.pinta
    ];
  };

}
