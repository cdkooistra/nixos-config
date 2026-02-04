{
  pkgs,
  hostName,
  ...
}:

let
  mkScript = name: text: pkgs.writeShellScriptBin name text;

  scripts = [
    (mkScript "nixrebuild" ''
      if [ -z "$NIXREBUILD_PATH" ]; then
        exit 1
      elif [ -z "$NIXOS_HOST" ]; then
        exit 1
      fi

      "$NIXREBUILD_PATH" "$1" "$NIXOS_HOST"
    '')

    (mkScript "nixupdate" ''
      if [ -z "$NIXUPDATE_PATH" ]; then
        exit 1
      fi

      "$NIXUPDATE_PATH"
    '')
  ];
in
{
  home.packages = scripts;

  # create .envrc file at ../flake.nix
  home.file.".nixos-config/.envrc" = {
    text = ''
      export NIXOS_HOST="${hostName}"
      export NIXREBUILD_PATH="$(pwd)/public/utils/rebuild.py"
      export NIXUPDATE_PATH="$(pwd)/public/utils/update.py"
    '';
  };
}
