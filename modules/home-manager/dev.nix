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
        config = {
          global.warn_timeout = "0s";
        };
      };
    };

    home = {
      packages = with pkgs; [
        unstable.devenv
        uv
        inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };
}
