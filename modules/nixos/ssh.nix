{ ... }:

{
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

  # only allow SSH via Tailscale interface
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ];
}
