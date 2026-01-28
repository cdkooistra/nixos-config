{
  config,
  pkgs,
  ...
}:

let
  mkScript = name: text: pkgs.writeShellScriptBin name text;

  scripts = [
    (mkScript "nixrebuild" ''
      if [ -z "$NIXREBUILD_PATH" ]; then
        exit 1
      elif [ -z "$NIXREBUILD_HOST" ]; then
        exit 1
      fi
      "$NIXREBUILD_PATH" "$1" "$NIXREBUILD_HOST"
    '')
  ];
in
{
  home.packages = scripts;

  # create .envrc file at ../flake.nix
  home.file.".nixos-config/.envrc" = {
    text = ''
      export NIXREBUILD_PATH="$(pwd)/public/utils/rebuild.py"
      export NIXREBUILD_HOST="${config.networking.hostName}"
    '';
  };
}
