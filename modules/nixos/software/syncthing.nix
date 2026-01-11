{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.software.syncthing;
in
{
  options.software.syncthing = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable syncthing";
    };

    deviceId = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Device ID for this Syncthing instance";
    };

    peers = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Manual map of hostName -> deviceId for all enabled hosts";
    };

    allPeers = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      internal = true;
      default = { };
      description = "Map of hostName -> deviceId for all enabled hosts";
    };

  };

  config = lib.mkIf cfg.enable {
    software.syncthing.allPeers = lib.mkMerge [
      { ${config.networking.hostName} = cfg.deviceId; }
    ];

    environment.systemPackages = with pkgs; [ syncthing ];

    services.syncthing = {
      enable = true;
      user = "connor";
      group = "users";
      dataDir = "/home/connor";
      configDir = "/home/connor/.config/syncthing";

      settings = {
        devices = {
          ${config.networking.hostName} = {
            id = cfg.deviceId;
          };
        }
        // (lib.mapAttrs (name: id: { inherit id; }) cfg.peers);

        folders = {
          "Documents" = {
            id = "e2lje-9wc4v";
            path = "/home/connor/Documents";
            devices = builtins.attrNames cfg.peers;
          };
        };
      };
    };

    # stop creating default sync folder
    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  };
}

# TODO: figure out how to do this garbage
# systemd.services.set-syncthing-password = {
#   description = "Set Syncthing GUI password from sops secret";
#   after = [ "network.target" ];
#   before = [ "syncthing.service" ];
#   wantedBy = [ "multi-user.target" ];

#   serviceConfig = {
#     Type = "oneshot";
#     User = "connor";
#     ExecStart = pkgs.writeShellScript "set-syncthing-pw" ''
#       '';
#   };
#
# };
