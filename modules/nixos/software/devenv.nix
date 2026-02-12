{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.software.devenv = {
    enable = lib.mkEnableOption "enable devenv";
  };

  config = lib.mkIf config.software.devenv.enable {
    nix.settings = {
      substituters = [ "https://devenv.cachix.org" ];
      trusted-public-keys = [ "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" ];
    };

    environment.systemPackages = with pkgs; [ devenv ];
  };
}
