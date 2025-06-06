{ config, lib, pkgs, ... }:

{
  options.software = {
    proton.enable = lib.mkEnableOption "enable Proton mail + pass";
  };

  config = lib.mkIf config.software.proton.enable {
    environment.systemPackages = [
      pkgs.proton-pass
      pkgs.protonmail-desktop
    ];
  };

}
