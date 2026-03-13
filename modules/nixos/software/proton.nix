{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.software.proton = {
    enable = lib.mkEnableOption "enable Proton suite";
  };

  config = lib.mkIf config.software.proton.enable {
    environment.systemPackages = with pkgs; [
      proton-pass
      protonmail-desktop
      protonvpn-gui
    ];
  };

}
