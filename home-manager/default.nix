{ config, lib, inputs, gnomeEnabled, anytypeAppImage, pkgs, ... }:

{
  # Create home dirs
  home.activation.ensureDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${config.home.homeDirectory}/Applications"
    mkdir -p "${config.home.homeDirectory}/Code"
  '';

  # Add home dirs to sidebar (GNOME)
  xdg.configFile."gtk-3.0/bookmarks" = {
    text = ''
      file://${config.home.homeDirectory}/Applications Applications
      file://${config.home.homeDirectory}/Code Code
      file://${config.home.homeDirectory}/Documents Documents
      file://${config.home.homeDirectory}/Music Music
      file://${config.home.homeDirectory}/Pictures Pictures
      file://${config.home.homeDirectory}/Videos Videos
      file://${config.home.homeDirectory}/Downloads Downloads
    '';
  };

  # AnyType
  # Fetch the AppImage into ~/Applications
  home.file."Applications/Anytype-${anytypeAppImage.version}.AppImage" = {
    source = builtins.fetchurl {
      url = anytypeAppImage.url;
      sha256 = anytypeAppImage.sha256;
    };
    executable = true;
  };

  home.username = "connor";
  home.homeDirectory = "/home/connor";
  home.stateVersion = "25.05";

  home.packages = [
    inputs.zen-browser.packages.${pkgs.system}.default
    pkgs.vscode
    pkgs.spotify
    pkgs.discord
    pkgs.obs-studio
  ];

  programs.git = {
    enable = true;
    userName = "Connor Kooistra";
    userEmail = "70811244+cdkooistra@users.noreply.github.com";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    enable = true;
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
