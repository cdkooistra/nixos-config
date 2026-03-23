{
  config,
  lib,
  ...
}:

let
  cfg = config.apps.onlyoffice;
in
{
  options.apps.onlyoffice = {
    enable = lib.mkEnableOption "Onlyoffice";
  };

  config = lib.mkIf cfg.enable {
    services.flatpak.packages = [
      "org.onlyoffice.desktopeditors"
    ];
  };
}
