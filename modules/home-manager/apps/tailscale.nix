{
  lib,
  osConfig,
  ...
}:

let
  cfg = osConfig.software.tailscale;
in
{
  config = lib.mkIf cfg.enable {
    services.tailscale-systray.enable = cfg.systray;
  };
}
