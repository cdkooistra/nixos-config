{
  config,
  lib,
  pkgs,
  ...
}:

let
  service = "hackernews";
  cfg = config.services."${service}";
  stateDir = "homepage-hackernews";

  fetchScript = pkgs.writers.writePython3Bin "homepage-hackernews-fetch" {
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ../../../utils/homepage-hackernews-fetch.py);
in
{
  options.services."${service}" = {
    enable = lib.mkEnableOption "Hacker News feed aggregator for Homepage";

    port = lib.mkOption {
      type = lib.types.int;
      default = 8105;
      description = "loopback port to serve the aggregated Hacker News feed on";
    };

    limit = lib.mkOption {
      type = lib.types.int;
      default = 15;
      description = "number of Hacker News top stories to fetch";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "5m";
      description = "how often to refresh the feed (systemd OnUnitActiveSec value)";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users."${service}" = {
      isSystemUser = true;
      group = "${service}";
    };
    users.groups."${service}" = { };

    systemd.services."${service}-fetch" = {
      description = "Fetch Hacker News top stories (firebase API)";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      environment = {
        HACKERNEWS_LIMIT = toString cfg.limit;
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe fetchScript;
        User = "${service}";
        Group = "${service}";
        StateDirectory = stateDir;
      };
    };

    systemd.timers."${service}-fetch" = {
      description = "Periodically fetch Hacker News top stories";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = cfg.interval;
      };
    };

    systemd.services."${service}-serve" = {
      description = "Serve the aggregated Hacker News feed";
      after = [ "${service}-fetch.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.busybox}/bin/busybox httpd -f -v -p 127.0.0.1:${toString cfg.port} -h /var/lib/${stateDir}";
        User = "${service}";
        Group = "${service}";
        StateDirectory = stateDir;
        Restart = "on-failure";
      };
    };
  };
}
