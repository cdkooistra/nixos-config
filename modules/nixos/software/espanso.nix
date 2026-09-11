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
      package = pkgs.unstable.espanso-wayland;
    };

    environment.systemPackages = with pkgs; [
      unstable.espanso-wayland
    ];
  };
}
