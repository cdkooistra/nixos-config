{
  config,
  lib,
  ...
}:

let
  cfg = config.apps.obsidian;
in
{
  options.apps.obsidian.enable = lib.mkEnableOption "Obsidian";

  config = lib.mkIf cfg.enable {
    services.flatpak.packages = [ "md.obsidian.Obsidian" ];
  };
}
