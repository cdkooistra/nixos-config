{
  hostName,
  ...
}:

{
  networking = {
    networkmanager.enable = true;
    enableIPv6 = false;
    nameservers = [
      "9.9.9.9" # quad9
    ];

    hostName = hostName; # auto infer based on flake input

    firewall.trustedInterfaces = [ "tailscale0" ];

  };
}
