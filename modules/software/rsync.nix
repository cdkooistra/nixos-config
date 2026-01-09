{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.software.rsync;
in
{
  options.software.rsync = {
    enable = lib.mkEnableOption "rsync";

    backups = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            src = lib.mkOption {
              type = lib.types.str;
              description = "local source to backup";
            };

            dst = lib.mkOption {
              type = lib.types.str;
              description = "remote destination in format user@host:/path";
            };

            schedule = lib.mkOption {
              type = lib.types.str;
              default = "daily";
              description = "systemd timer schedule";
            };
          };
        }
      );
      default = { };
      description = "backup job definitions";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ rsync ];

    # Create a systemd service for each backup job
    systemd.services = lib.mapAttrs' (
      name: backup:
      lib.nameValuePair "rsync-backup-${name}" {
        description = "rsync backup job: ${name}";
        serviceConfig = {
          Type = "oneshot";
          User = "root"; # TODO: should this be configurable?
          ExecStart = "${pkgs.rsync}/bin/rsync -av --delete '${backup.src}' '${backup.dst}'";
        };
      }
    ) cfg.backups;

    # Create a systemd timer for each backup job
    systemd.timers = lib.mapAttrs' (
      name: backup:
      lib.nameValuePair "rsync-backup-${name}" {
        description = "Timer for rsync backup job: ${name}";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = backup.schedule;
          Persistent = true;
        };
      }
    ) cfg.backups;
  };
}
