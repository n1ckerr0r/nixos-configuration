{ pkgs, ... }:

let
  niriBatteryWarning = pkgs.writeShellApplication {
    name = "niri-battery-warning";
    runtimeInputs = with pkgs; [
      coreutils
      libnotify
    ];
    text = ''
      set -u

      warned_low=0
      warned_critical=0

      get_battery_dir() {
        local battery

        for battery in /sys/class/power_supply/BAT*; do
          [ -d "$battery" ] || continue
          [ -r "$battery/capacity" ] || continue
          [ -r "$battery/status" ] || continue
          printf '%s\n' "$battery"
          return 0
        done

        return 1
      }

      while true; do
        if battery_dir="$(get_battery_dir)"; then
          capacity="$(cat "$battery_dir/capacity")"
          status="$(cat "$battery_dir/status")"

          if [ "$status" = "Discharging" ]; then
            if [ "$capacity" -le 5 ] && [ "$warned_critical" -eq 0 ]; then
              notify-send -a Battery -u critical -h string:x-canonical-private-synchronous:battery-warning "Battery critical" "Battery is at $capacity%. Connect the charger."
              warned_critical=1
              warned_low=1
            elif [ "$capacity" -le 10 ] && [ "$warned_low" -eq 0 ]; then
              notify-send -a Battery -u critical -h string:x-canonical-private-synchronous:battery-warning "Battery low" "Battery is at $capacity%. Connect the charger."
              warned_low=1
            fi
          else
            warned_low=0
            warned_critical=0
          fi

          if [ "$capacity" -gt 10 ]; then
            warned_low=0
            warned_critical=0
          fi
        fi

        sleep 60
      done
    '';
  };

  # Niri starts this helper from config.kdl. Keep only small session services
  # here; compositor behavior and keybindings live in dotfiles/niri/config.kdl.
  niriSessionStartup = pkgs.writeShellApplication {
    name = "niri-session-startup";
    runtimeInputs = with pkgs; [
      blueman
      networkmanagerapplet
    ];
    text = ''
      nm-applet --indicator &
      blueman-applet &
    '';
  };

  niriScreenshotOcr = pkgs.writeShellApplication {
    name = "niri-screenshot-ocr";
    runtimeInputs = with pkgs; [
      coreutils
      grim
      libnotify
      slurp
      (tesseract.override {
        enableLanguages = [
          "eng"
          "rus"
        ];
      })
      wl-clipboard
      zenity
    ];
    text = ''
      set -u

      screenshots_dir="$HOME/Pictures/Screenshots"
      runtime_dir="''${XDG_RUNTIME_DIR:-/tmp}"
      image="$screenshots_dir/OCR Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"
      text_file="$runtime_dir/niri-screenshot-ocr.txt"

      mkdir -p "$screenshots_dir"

      geometry="$(slurp)" || exit 0
      [ -n "$geometry" ] || exit 0

      grim -g "$geometry" "$image"
      tesseract "$image" stdout -l eng+rus --psm 6 > "$text_file" 2>/dev/null || {
        notify-send -u critical "Screenshot OCR" "Could not recognize text."
        exit 1
      }

      if [ ! -s "$text_file" ]; then
        printf '%s\n' "No text recognized." > "$text_file"
      fi

      wl-copy < "$text_file"
      notify-send "Screenshot OCR" "Text copied to clipboard."

      zenity \
        --text-info \
        --editable \
        --title="Screenshot OCR" \
        --filename="$text_file" \
        --width=800 \
        --height=500 >/dev/null 2>&1 || true
    '';
  };

  niriPowerMenu = pkgs.writeShellApplication {
    name = "niri-power-menu";
    runtimeInputs = with pkgs; [
      coreutils
      gnused
      grim
      imagemagick
      wlogout
    ];
    text = ''
      runtime_dir="''${XDG_RUNTIME_DIR:-/tmp}"
      menu_dir="$runtime_dir/niri-power-menu"
      raw="$menu_dir/background.png"
      blurred="$menu_dir/background-blurred.png"
      css="$menu_dir/style.css"

      mkdir -p "$menu_dir"
      if grim "$raw"; then
        magick "$raw" -filter Gaussian -blur 0x30 "$blurred"
      else
        magick -size 1920x1080 "xc:#11111b" "$blurred"
      fi

      sed \
        -e "s|@BACKGROUND@|$blurred|g" \
        -e "s|@ICON_DIR@|${pkgs.wlogout}/share/wlogout|g" \
        "$HOME/.config/wlogout/style.css" > "$css"

      exec wlogout \
        --protocol layer-shell \
        --no-span \
        --buttons-per-row 3 \
        --column-spacing 48 \
        --row-spacing 36 \
        --margin 96 \
        --layout "$HOME/.config/wlogout/layout" \
        --css "$css"
    '';
  };

in
{
  home.packages = [
    pkgs.bibata-cursors
    pkgs.swaybg
    niriPowerMenu
    niriBatteryWarning
    niriScreenshotOcr
    niriSessionStartup
  ];

  systemd.user.services.noctalia-shell = {
    Unit = {
      Description = "Noctalia shell";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "/run/current-system/sw/bin/noctalia-shell";
      Restart = "on-failure";
      RestartSec = 2;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.niri-battery-warning = {
    Unit = {
      Description = "Low battery notification watcher";
      After = [ "graphical-session-pre.target" ];
    };

    Service = {
      ExecStart = "${niriBatteryWarning}/bin/niri-battery-warning";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "default.target" ];
  };

}
