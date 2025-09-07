{ config, lib, pkgs, ... }:

{
  options.software.proton = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable Proton mail + pass"; 
    };
  };

  config = lib.mkIf config.software.proton.enable {
    environment.systemPackages = [
      pkgs.proton-pass
      pkgs.protonmail-desktop
    ];
  };

}
