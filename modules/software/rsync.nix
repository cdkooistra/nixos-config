# this module is very wip
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

            # TODO:
            # instead of string src and dst
            # try and see if we can choose from list of
            # available systems, derived from *.nix in /hosts/
            src = lib.mkOption {
              type = lib.types.str;
              description = "local source to backup";
            };

            dst = lib.mkOption {
              type = lib.types.str;
              description = "remote destination in format user@host:/path";
            };

            # TODO: what user should we use?

            schedule = lib.mkOption {
              type = lib.types.str;
              default = "12:00";
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
          User = "connor"; # TODO: should this be configurable?
          ExecStart = "${pkgs.rsync}/bin/rsync -av -e '${pkgs.openssh}/bin/ssh' '${backup.src}' '${backup.dst}'";
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
