{ lib, config, ... }:

let
  cfg = config.system.appformats;
in
{
  options.system.appformats = {
    appimage.enable = lib.mkEnableOption "AppImage";
    flatpak.enable = lib.mkEnableOption "Flatpak";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.appimage.enable {
      programs.appimage.enable = true;
      programs.appimage.binfmt = true;
    })
    (lib.mkIf cfg.flatpak.enable {
      services.flatpak.enable = true;
    })
  ];
}
