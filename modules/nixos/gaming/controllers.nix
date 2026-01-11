{
  config,
  lib,
  ...
}:

let
  cfg = config.gaming.controllers;
in
{
  options.gaming.controllers = {
    xone.enable = lib.mkEnableOption "Xbox One controller";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.xone.enable {
      hardware.xone.enable = true;
    })

    # other controllers here..
  ];
}
