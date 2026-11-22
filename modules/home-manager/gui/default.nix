{ config, ... }:

{
  imports = [
    ./de
    ./compositor
  ];

  # available as a function argument in every Home Manager module
  _module.args.mkLink = path: {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixos-config/public/modules/home-manager/gui/${path}";
    force = true;
  };
}
