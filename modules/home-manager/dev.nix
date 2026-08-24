{
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}:

{
  config = lib.mkIf osConfig.system.dev.enable {
    programs = {
      direnv = {
        enable = true;
        silent = true;
        nix-direnv.enable = true;
      };
    };

    home = {
      packages = with pkgs; [
        devenv
        uv
        inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };
}
