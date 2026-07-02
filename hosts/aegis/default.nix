#
# Aegis, the shield of Zeus, guards the network at the edge.
#

{
  mkHost,
  network,
  secrets,
  ...
}:

mkHost {
  name = "aegis";
  arch = "x86_64-linux";

  system = {
    age = {
      identityPaths = [
        "/home/connor/.ssh/id_ed25519"
      ];
      secrets.passwd.file = "${secrets}/passwd.age";
    };

    # debatable, because this system does not need GUI/graphic compute
    graphics.intel.enable = true;

    software = {
      docker.enable = true;
      tailscale = {
        enable = true;
        ssh = true;

        serve = {
          enable = false;
          # TODO: services = { };
        };

        auth = {
          enable = true;
          file = "${secrets}/tailscale.age";
          params = {
            preauthorized = true;
            ephemeral = false;
          };
          tags = [ "tag:server" ];
        };
      };
    };

    services = {
      pihole.enable = true;
    };

    system = {
      openssh = {
        enable = true;
        allowTailscale = true;
        allowLan = true;
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

    system.stateVersion = "26.05";
  };
}
