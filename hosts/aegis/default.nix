#
# Aegis, the shield of Zeus, guards the network at the edge.
#

{ mkHost, network, ... }:

mkHost {
  name = "aegis";
  arch = "x86_64-linux";

  system = {
    # debatable, because this system does not need GUI/graphic compute
    graphics.intel.enable = true;

    software = {
      tailscale = {
        enable = true;
        ssh = true;

        serve = {
          enable = true;
          # TODO: services = { };
        };
      };
    };

    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    hardware.enableAllFirmware = true;

    system.stateVersion = "26.05"; # TODO: this should probably be 26.05
  };
}
