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
    services.espanso = {
      enable = true;
      package = pkgs.espanso-wayland;
    };

    # TODO: find a way to properly set keyboard layout based on services.xserver.xkb config
    # espanso needs this to detect input

    environment.systemPackages = with pkgs; [
      espanso-wayland
    ];
  };
}
