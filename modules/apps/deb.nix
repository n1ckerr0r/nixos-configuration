{ pkgs, ... }:

let
  debbox = pkgs.writeShellApplication {
    name = "debbox";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.distrobox
      pkgs.gawk
    ];
    text = ''
      set -eu

      box_name=debian
      box_image=docker.io/library/debian:stable

      ensure_box() {
        if ! distrobox list --no-color | awk -F '|' -v name="$box_name" '
          NR > 1 {
            candidate = $2
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", candidate)
            if (candidate == name) found = 1
          }
          END { exit !found }
        '; then
          distrobox create --name "$box_name" --image "$box_image" --yes
        fi
      }

      case "''${1:-}" in
        install)
          if [ "$#" -ne 2 ] || [ ! -f "$2" ]; then
            echo "Usage: debbox install /absolute/path/to/package.deb" >&2
            exit 64
          fi

          package_path="$(realpath "$2")"
          ensure_box
          distrobox enter "$box_name" -- sudo apt-get update
          distrobox enter "$box_name" -- sudo apt-get install -y "$package_path"
          echo "Installed into the $box_name Distrobox container."
          echo "For a GUI application, export its launcher with:"
          echo "  distrobox enter $box_name -- distrobox-export --app /path/to/executable"
          ;;
        enter)
          ensure_box
          exec distrobox enter "$box_name"
          ;;
        *)
          echo "Usage: debbox {install <package.deb>|enter}" >&2
          exit 64
          ;;
      esac
    '';
  };
in
{
  # Debian packages must not be installed into NixOS's immutable root filesystem.
  # Distrobox provides a Debian userspace where APT resolves their dependencies.
  environment.systemPackages = [
    pkgs.distrobox
    debbox
  ];
}
