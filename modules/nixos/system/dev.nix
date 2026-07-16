{
  lib,
  ...
}:

{
  # osConfig option for home-manager dev configuration
  options.system.dev = {
    enable = lib.mkEnableOption "Development";
  };
}
