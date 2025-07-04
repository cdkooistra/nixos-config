{ config, lib, inputs, gnomeEnabled, pkgs, ... }:

{
  home.username = "connor";
  home.homeDirectory = "/home/connor";
  home.stateVersion = "25.05";

  home.packages = [
    inputs.zen-browser.packages.${pkgs.system}.default
    pkgs.vscode
    pkgs.spotify
    pkgs.discord
    pkgs.obs-studio
    pkgs.anytype
  ];

  # to git file
  programs.git = {
    enable = true;
    userName = "Connor Kooistra";
    userEmail = "70811244+cdkooistra@users.noreply.github.com";
  };

  imports = if gnomeEnabled 
  then [ ./dconf.nix ]
  else [];

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/connor/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "code";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
