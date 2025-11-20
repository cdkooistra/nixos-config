{ config, lib, pkgs, inputs, ... }:

{
  options.software.flox = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable flox env manager";
    };
  };

  config = lib.mkIf config.software.flox.enable {
    nix.settings = {
      substituters = [ "https://cache.flox.dev" ];
      trusted-public-keys = [ "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs=" ];
    };

    environment.systemPackages = [
      inputs.flox.packages.${pkgs.system}.default
    ];
  };
}
