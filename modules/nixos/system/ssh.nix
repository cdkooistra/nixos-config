{ config, lib, ... }:

let
  cfg = config.system.openssh;
in
{
  options.system.openssh = {
    enable = lib.mkEnableOption "SSH server";
    ports = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ ];
      description = "which ports to listen on for SSH using sshd";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      openFirewall = true;
      ports = cfg.ports;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "connor" ];
      };
    };
  };
}
