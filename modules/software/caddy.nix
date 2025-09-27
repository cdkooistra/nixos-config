{ config, lib, pkgs, ... }:

{
  options.software.caddy = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable Caddy";
    };
  };

  config = lib.mkIf config.software.caddy.enable {
    services.caddy.enable = true;

    # TODO: we could declaratively configure our Caddyfile here
  };

}
