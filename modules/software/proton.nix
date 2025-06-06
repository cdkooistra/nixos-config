{ config, lib, pkgs, ... }:

{
  options = {
    proton.enable = lib.mkEnableOption "enable Proton mail + pass";
  };

  config = lib.mkIf config.proton.enable {
    environment.systemPackages = [
      pkgs.proton-pass
      pkgs.protonmail-desktop
    ];
  };
  
}
