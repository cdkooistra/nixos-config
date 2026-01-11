{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.software.espanso = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable Espanso";
    };
  };

  config = lib.mkIf config.software.espanso.enable {
    services.espanso.enable = true;

    environment.systemPackages = with pkgs; [
      espanso-wayland
    ];
  };
}
