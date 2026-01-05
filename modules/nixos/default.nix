{ pkgs, ... }:

{
  imports = [
    ./locale.nix
    ./sops.nix
    ./networking.nix
    ./user.nix
    ./appimage.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  # enable this setting to solve some issues with unpatched dynamic binaries
  # by doing some workaround for the dynamic linker
  # this helps set up remote vscode server :)
  programs.nix-ld.enable = true;

  # setup lsp and formatter
  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    nixd
  ];
}
