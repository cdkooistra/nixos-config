{ pkgs, ... }:
{
  programs = {
    direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
    };

    zed-editor = {
      enable = true;
      package = pkgs.zed-editor;
    };
  };

  home = {
    packages = with pkgs; [
      python3
      uv
    ];
  };
}
