{ config, lib, ... }:

let
  cfg = config.system.openssh;
in
{
  options.system.openssh = {
    enable = lib.mkEnableOption "SSH server";
    allowLan = lib.mkEnableOption "allow SSH over LAN";
    allowTailscale = lib.mkEnableOption "allow SSH over Tailscale";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "connor" ];
      };
    };

    networking.firewall = {
      # allow SSH via Tailscale interface
      interfaces.tailscale0.allowedTCPPorts = lib.mkIf cfg.allowTailscale [ 22 ];
      # allow SSH locally
      allowedTCPPorts = lib.mkIf cfg.allowLan [ 22 ];
    };
  };
}
