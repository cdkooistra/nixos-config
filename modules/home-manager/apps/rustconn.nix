{
  config,
  lib,
  ...
}:

let
  cfg = config.apps.rustconn;
in
{
  options.apps.rustconn = {
    enable = lib.mkEnableOption "rustconn";
  };

  config = lib.mkIf cfg.enable {
    services.flatpak.packages = [
      "io.github.totoshko88.RustConn"
    ];
  };
}
