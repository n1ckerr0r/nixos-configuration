{ pkgs, ... }:

{
  # The start command opens the usual application set in a fixed order.
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "start";
      runtimeInputs = with pkgs; [
        gnugrep # grep for window detection in Niri.
        util-linux # setsid for launching applications in the background.
        niri # niri msg for Niri sessions.
        wireplumber # wpctl for muting and setting volume.
      ];
      text = ''
        set -u

        log() {
          printf '%s\n' "$*"
        }

        warn() {
          printf 'start: %s\n' "$*" >&2
        }

        have() {
          command -v "$1" >/dev/null 2>&1
        }

        launch() {
          if have setsid; then
            setsid -f "$@" >/dev/null 2>&1
          else
            "$@" >/dev/null 2>&1 &
          fi
        }

        launch_first_found() {
          local command_name

          for command_name in "$@"; do
            if have "$command_name"; then
              launch "$command_name"
              return 0
            fi
          done

          warn "command not found: $*"
          return 1
        }

        switch_workspace() {
          local workspace_index="$1"
          local niri_workspace=$((workspace_index + 1))

          if have niri; then
            niri msg action focus-workspace "$niri_workspace" >/dev/null 2>&1 && sleep 0.8 && return 0
          fi

          warn "niri is not available, could not switch workspace"
          return 1
        }

        open_obsidian() {
          launch_first_found obsidian
        }

        open_telegram() {
          launch_first_found telegram-desktop Telegram
        }

        open_chrome() {
          if have google-chrome; then
            launch google-chrome --new-window
          elif have google-chrome-stable; then
            launch google-chrome-stable --new-window
          else
            warn "google-chrome not found"
          fi
        }

        mute_volume() {
          if have wpctl; then
            wpctl set-volume @DEFAULT_AUDIO_SINK@ 0 >/dev/null 2>&1
            wpctl set-mute @DEFAULT_AUDIO_SINK@ 1 >/dev/null 2>&1
          else
            warn "wpctl not found, could not mute volume"
          fi
        }

        wait_for_window() {
          local pattern="$1"
          local attempt=0

          if ! have niri; then
            return 0
          fi

          while [ "$attempt" -lt 30 ]; do
            if niri msg windows 2>/dev/null | grep -qiE "$pattern"; then
              return 0
            fi

            attempt=$((attempt + 1))
            sleep 0.5
          done

          warn "window did not appear in time: $pattern"
          return 1
        }

        mute_volume

        log "Opening applications in required order"
        open_chrome
        sleep 1.5
        open_obsidian
        wait_for_window 'obsidian|md\.Obsidian|md\.obsidian\.Obsidian' || true

        sleep 1

        switch_workspace 1
        open_telegram

        log "Done"
      '';
    })
  ];
}
