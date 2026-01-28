{
  lib,
  systemOptions,
  ...
}:

{
  imports = lib.flatten [
    # always import
    ./core.nix
    ./utils.nix

    # config
    ../../../config/ssh.nix

    # conditionally import
    (lib.optional systemOptions.desktops.gnome.enable ./desktops/gnome.nix)
    # (lib.optional systemOptions.desktops.cosmic.enable ./desktops/cosmic.nix)
  ];
}
