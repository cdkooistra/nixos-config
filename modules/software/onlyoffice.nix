{ config, lib, pkgs, ... }:

{
  options.software.onlyoffice = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable Onlyoffice";
    };
  };

  config = lib.mkIf config.software.onlyoffice.enable {
    environment.systemPackages = [
      pkgs.onlyoffice-desktopeditors
    ];
  };

}
