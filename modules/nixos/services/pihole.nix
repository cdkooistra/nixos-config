{
  config,
  lib,
  ...
}:

let
  service = "pihole";
  cfg = config.services."${service}";
in
{
  options.services."${service}" = {
    enable = lib.mkEnableOption "pi-hole";
  };

  config = lib.mkIf cfg.enable {
    services = {
      pihole-ftl = {
        enable = true;
        settings = {
          dns = {
            upstreams = [
              "86.54.11.13" # dns4eu
            ];
            listeningMode = "ALL";
          };
        };
        lists = [
          {
            url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
            type = "block";
            enabled = true;
            description = "hagezi blocklist";
          }
        ];
      };
      pihole-web = {
        enable = true;
        ports = [ "443" ];
      };
    };

    # Restrict who can actually reach port 53
    networking.firewall = {
      interfaces = {
        "tailscale0" = {
          allowedTCPPorts = [ 53 ];
          allowedUDPPorts = [ 53 ];
        };
        "enp1s0" = {
          allowedTCPPorts = [ 53 ];
          allowedUDPPorts = [ 53 ];
        };
      };
    };
  };
}
