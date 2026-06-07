{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.graphics.displaylink;
in
{
  options.graphics.displaylink = {
    enable = lib.mkEnableOption "enable DisplayLink drivers";
  };

  config = lib.mkIf cfg.enable {
    # apparently Displaylink for Wayland needs evdi module set like this
    boot = {
      extraModulePackages = [ config.boot.kernelPackages.evdi ];
      initrd = {
        # kernel modules that are always loaded by initrd
        kernelModules = [
          "evdi"
        ];
      };
    };

    services.xserver.videoDrivers = [
      "displaylink"
    ];

    environment.systemPackages = with pkgs; [
      displaylink
    ];

    systemd.services.dlm.wantedBy = [ "multi-user.target" ];

    # some freaky with mutter (gnome)
    environment.sessionVariables = {
      MUTTER_DEBUG_ENABLE_ATOMIC_KMS = "0";
    };
  };
}
