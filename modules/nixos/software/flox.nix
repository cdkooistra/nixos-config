{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  options.software.flox = {
    enable = lib.mkEnableOption "flox env";
  };

  config = lib.mkIf config.software.flox.enable {
    nix.settings = {
      extra-substituters = [ "https://cache.flox.dev" ];
      extra-trusted-public-keys = [ "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs=" ];
    };

    environment.systemPackages = [
      inputs.flox.packages.${pkgs.system}.default
    ];
  };
}
