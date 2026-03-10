{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./solidtime.nix
    ./immich.nix
    ./browsers.nix
    ./stirling.nix
  ];

  # this imports the tailscale sidecar only for service.nix files defined in this folder
  config._module.args.tailscale = import ./tailscale-sidecar.nix { inherit config lib pkgs; };
}
