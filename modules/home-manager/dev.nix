{ pkgs, inputs, ... }:
{
  programs = {
    direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
    };
  };

  home = {
    packages = with pkgs; [
      python3
      uv
      inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
