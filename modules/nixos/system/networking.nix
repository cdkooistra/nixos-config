{
  hostName,
  ...
}:

{
  networking = {
    networkmanager.enable = true;
    enableIPv6 = false;
    nameservers = [
      "86.54.11.13" # dns4eu
    ];

    hostName = hostName; # auto infer based on flake input

    firewall.trustedInterfaces = [ "tailscale0" ];

  };
}
