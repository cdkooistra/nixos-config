{
  config,
  lib,
  ...
}:

let
  cfg = config.apps.pinta;
in
{
  options.apps.pinta = {
    enable = lib.mkEnableOption "Pinta";
  };

  config = lib.mkIf cfg.enable {
    services.flatpak.packages = [
      "com.github.PintaProject.Pinta"
    ];
  };
}
