{
  lib,
  config,
  ...
}:

let
  cfg = config.software.restic;

  passwordSecretName = repoName: "restic-${repoName}-password";
  envSecretName = repoName: "restic-${repoName}-env";

  # one logical backup job fanned out to each of its target repositories,
  # so the same source can be shipped to e.g. both hermes and sisyphus
  jobs = lib.flatten (
    lib.mapAttrsToList (
      name: backup: map (repoName: { inherit name backup repoName; }) backup.repositories
    ) cfg.backups
  );
in
{
  options.software.restic = {
    enable = lib.mkEnableOption "restic backups";

    repositories = lib.mkOption {
      default = { };
      description = "restic repositories, referenced by name from `backups`";
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            url = lib.mkOption {
              type = lib.types.str;
              description = "restic repository URL, e.g. sftp:user@host:/path or b2:bucket:/path";
            };

            passwordFile = lib.mkOption {
              type = lib.types.path;
              description = "path to an age-encrypted file containing the repository password";
            };

            environmentFile = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = "path to an age-encrypted env file with backend credentials, if the backend needs one";
            };

            extraOptions = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "extra restic `--option`/`-o` flags, e.g. to override the sftp connection command since backup jobs run as root";
              example = [
                "sftp.command='ssh connor@sisyphus -i /home/connor/.ssh/id_ed25519 -s sftp'"
              ];
            };
          };
        }
      );
    };

    backups = lib.mkOption {
      default = { };
      description = "restic backup jobs for arbitrary services";
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            repositories = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              description = "names of the repositories (from `software.restic.repositories`) to back this job up to";
            };

            paths = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              description = "paths to include in the backup";
            };

            exclude = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };

            backupPrepareCommand = lib.mkOption {
              type = lib.types.nullOr lib.types.lines;
              default = null;
              description = "shell command to run before the backup, e.g. dumping a database to a file under one of `paths`";
            };

            backupCleanupCommand = lib.mkOption {
              type = lib.types.nullOr lib.types.lines;
              default = null;
              description = "shell command to run after the backup, e.g. removing a temporary dump file";
            };

            tags = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };

            schedule = lib.mkOption {
              type = lib.types.str;
              default = "daily";
              description = "systemd OnCalendar schedule";
            };

            limitUploadKb = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = null;
              description = "cap upload bandwidth to this many KiB/s (restic `--limit-upload`)";
            };

            limitDownloadKb = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = null;
              description = "cap download bandwidth to this many KiB/s (restic `--limit-download`)";
            };

            keep = {
              daily = lib.mkOption {
                type = lib.types.int;
                default = 3;
              };
              weekly = lib.mkOption {
                type = lib.types.int;
                default = 2;
              };
            };

            # TODO: notifications
            #
            # notify = {
            #   onSuccess = lib.mkOption {
            #     type = lib.types.nullOr lib.types.lines;
            #     default = null;
            #     description = "shell command to run after a successful backup";
            #   };
            #   onFailure = lib.mkOption {
            #     type = lib.types.nullOr lib.types.lines;
            #     default = null;
            #     description = "shell command to run when the backup fails";
            #   };
            # };
          };
        }
      );
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = lib.mkMerge (
      lib.mapAttrsToList (
        name: repo:
        {
          "${passwordSecretName name}".file = repo.passwordFile;
        }
        // lib.optionalAttrs (repo.environmentFile != null) {
          "${envSecretName name}".file = repo.environmentFile;
        }
      ) cfg.repositories
    );

    services.restic.backups = lib.listToAttrs (
      map (
        job:
        let
          repo = cfg.repositories.${job.repoName};
        in
        {
          name = "${job.name}-${job.repoName}";
          value = {
            repository = repo.url;
            passwordFile = config.age.secrets.${passwordSecretName job.repoName}.path;
            environmentFile =
              if repo.environmentFile != null then
                config.age.secrets.${envSecretName job.repoName}.path
              else
                null;

            paths = job.backup.paths;
            exclude = job.backup.exclude;
            extraOptions = repo.extraOptions;
            extraBackupArgs =
              map (tag: "--tag=${tag}") job.backup.tags
              ++ lib.optional (
                job.backup.limitUploadKb != null
              ) "--limit-upload=${toString job.backup.limitUploadKb}"
              ++ lib.optional (
                job.backup.limitDownloadKb != null
              ) "--limit-download=${toString job.backup.limitDownloadKb}";

            backupPrepareCommand = job.backup.backupPrepareCommand;
            backupCleanupCommand = job.backup.backupCleanupCommand;

            initialize = true;

            timerConfig = {
              OnCalendar = job.backup.schedule;
              Persistent = true;
            };

            pruneOpts = [
              "--keep-daily ${toString job.backup.keep.daily}"
              "--keep-weekly ${toString job.backup.keep.weekly}"
            ];

            # TODO: wire up job.backup.notify once the `notify` option above is uncommented
            # backupCleanupCommand runs on success only, so onSuccess could piggyback there,
            # but onFailure needs its own hook since restic's systemd unit doesn't expose one -
            # options are an `OnFailure=` unit on the generated `restic-backups-${name}.service`,
            # or wrapping the ExecStart in a script that traps non-zero exit.
          };
        }
      ) jobs
    );
  };
}
