{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.system.appformats;
in
{
  options.system.appformats = {
    appimage = {
      enable = lib.mkEnableOption "AppImage";
      extraPkgs = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "packages to make available to AppImages at runtime.";
      };
    };
    flatpak.enable = lib.mkEnableOption "Flatpak";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.appimage.enable {
      programs.appimage = {
        enable = true;
        binfmt = true;
        package = pkgs.appimage-run.override {
          extraPkgs = pkgs: cfg.appimage.extraPkgs;
        };
      };
    })
    (lib.mkIf cfg.flatpak.enable {
      services.flatpak.enable = true;
    })
  ];
}
