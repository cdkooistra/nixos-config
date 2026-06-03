{ pkgs, ... }:
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
    ];
  };
}
