{ pkgs, ... }:

let
  adguardvpnBypass = pkgs.writeShellApplication {
    name = "adguardvpn-sites";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gawk
      pkgs.gnugrep
      pkgs.iproute2
    ];
    text = ''
            set -euo pipefail

            state_dir="/var/lib/adguardvpn-bypass"
            domains_file="$state_dir/domains"
            priority_start=30750
            priority_end=30799
            vpn_rule_priority=30801
            vpn_table=880
            route_proto=186

            usage() {
              cat >&2 <<'EOF'
      Usage:
        adguardvpn-sites add DOMAIN_OR_URL
        adguardvpn-sites remove DOMAIN_OR_URL
        adguardvpn-sites list
        adguardvpn-sites status [DOMAIN_OR_URL]
        adguardvpn-sites clear
      EOF
            }

            normalize_domain() {
              local input="$1"

              awk '
                function trim(value) {
                  gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
                  return value
                }

                function join(labels, start, stop, result, i) {
                  result = labels[start]
                  for (i = start + 1; i <= stop; i++) {
                    result = result "." labels[i]
                  }
                  return result
                }

                function registrable_domain(host, labels, count, suffix2) {
                  host = tolower(host)
                  sub(/^www[.]/, "", host)
                  count = split(host, labels, ".")

                  if (count < 3) {
                    return host
                  }

                  suffix2 = labels[count - 1] "." labels[count]
                  if (suffix2 ~ /^(spb|msk|com|net|org|edu|gov|ac|co)[.](ru|uk)$/) {
                    return join(labels, count - 2, count)
                  }

                  return labels[count - 1] "." labels[count]
                }

                {
                  value = trim($0)
                  sub(/^[a-z][a-z0-9+.-]*:\/\//, "", value)
                  sub(/^[^@/]+@/, "", value)
                  sub(/[/?#].*$/, "", value)
                  sub(/:[0-9]+$/, "", value)
                  sub(/[.]$/, "", value)

                  if (value == "ozon") {
                    value = "ozon.ru"
                  } else if (value == "spotify") {
                    value = "spotify.com"
                  }

                  if (value !~ /^[A-Za-z0-9.-]+$/ || value !~ /[.]/) {
                    exit 1
                  }

                  print registrable_domain(value)
                }
              ' <<< "$input"
            }

            need_root() {
              if [ "$(id -u)" -ne 0 ]; then
                if [ -x /run/wrappers/bin/sudo ]; then
                  exec /run/wrappers/bin/sudo "$0" "$@"
                fi
                exec sudo "$0" "$@"
              fi
            }

            ensure_state_dir() {
              mkdir -p "$state_dir"
              touch "$domains_file"
            }

            ensure_state_file_readable() {
              if [ ! -e "$domains_file" ]; then
                mkdir -p "$state_dir" 2>/dev/null || true
                touch "$domains_file" 2>/dev/null || true
              fi
            }

            collect_hosts() {
              local domain="$1"
              printf '%s\n' "$domain"
              case "$domain" in
                www.*) ;;
                *) printf 'www.%s\n' "$domain" ;;
              esac
            }

            collect_ipv4s() {
              local domain="$1"
              while IFS= read -r host; do
                getent ahostsv4 "$host" 2>/dev/null | awk '{ print $1 }'
              done < <(collect_hosts "$domain") | awk '!seen[$0]++'
            }

            collect_ipv6s() {
              local domain="$1"
              while IFS= read -r host; do
                getent ahostsv6 "$host" 2>/dev/null | awk '$1 !~ /^::ffff:/ { print $1 }'
              done < <(collect_hosts "$domain") | awk '!seen[$0]++'
            }

            clear_rule_family() {
              local family_flag="$1"

              if [ -n "$family_flag" ]; then
                ip "$family_flag" rule show
              else
                ip rule show
              fi | awk -v min="$priority_start" -v max="$priority_end" '
                $1 ~ /:$/ {
                  pref = $1
                  sub(":", "", pref)
                  if (pref >= min && pref <= max) {
                    print pref
                  }
                }
              ' | sort -rn | while IFS= read -r pref; do
                [ -n "$pref" ] || continue
                if [ -n "$family_flag" ]; then
                  ip "$family_flag" rule del pref "$pref"
                else
                  ip rule del pref "$pref"
                fi
              done
            }

            clear_route_family() {
              local family_flag="$1"

              if [ -n "$family_flag" ]; then
                ip "$family_flag" route flush table "$vpn_table" proto "$route_proto" >/dev/null 2>&1 || true
              else
                ip route flush table "$vpn_table" proto "$route_proto" >/dev/null 2>&1 || true
              fi
            }

            default_v4_fields() {
              ip -4 route show table main default | awk '
                NR == 1 {
                  for (i = 1; i <= NF; i++) {
                    if ($i == "via") via = $(i + 1)
                    if ($i == "dev") dev = $(i + 1)
                    if ($i == "src") src = $(i + 1)
                  }
                  if (dev != "") {
                    print via "\t" dev "\t" src
                  }
                }
              '
            }

            default_v6_fields() {
              ip -6 route show table main default | awk '
                NR == 1 {
                  for (i = 1; i <= NF; i++) {
                    if ($i == "via") via = $(i + 1)
                    if ($i == "dev") dev = $(i + 1)
                  }
                  if (dev != "") {
                    print via "\t" dev
                  }
                }
              '
            }

            add_bypass_v4_route() {
              local cidr="$1"
              local fields via dev src
              local -a route_args

              fields="$(default_v4_fields)"
              [ -n "$fields" ] || return 0
              via="$(printf '%s\n' "$fields" | awk -F '\t' '{ print $1 }')"
              dev="$(printf '%s\n' "$fields" | awk -F '\t' '{ print $2 }')"
              src="$(printf '%s\n' "$fields" | awk -F '\t' '{ print $3 }')"

              route_args=(table "$vpn_table" "$cidr")

              if [ -n "$via" ]; then
                route_args+=(via "$via" dev "$dev")
              else
                route_args+=(dev "$dev")
              fi

              if [ -n "$src" ]; then
                route_args+=(src "$src")
              fi

              route_args+=(proto "$route_proto" metric 1)
              ip -4 route replace "''${route_args[@]}"
            }

            add_bypass_v6_route() {
              local cidr="$1"
              local fields via dev

              fields="$(default_v6_fields)"
              if [ -z "$fields" ]; then
                ip -6 route replace unreachable "$cidr" table "$vpn_table" proto "$route_proto" metric 1
                return 0
              fi

              via="$(printf '%s\n' "$fields" | awk -F '\t' '{ print $1 }')"
              dev="$(printf '%s\n' "$fields" | awk -F '\t' '{ print $2 }')"

              if [ -n "$via" ]; then
                ip -6 route replace table "$vpn_table" "$cidr" via "$via" dev "$dev" proto "$route_proto" metric 1
              else
                ip -6 route replace table "$vpn_table" "$cidr" dev "$dev" proto "$route_proto" metric 1
              fi
            }

            apply_rules() {
              local pref="$priority_start"
              local domain
              local ip

              ensure_state_dir
              clear_rule_family ""
              clear_rule_family "-6"
              clear_route_family ""
              clear_route_family "-6"

              while IFS= read -r domain; do
                [ -n "$domain" ] || continue

                while IFS= read -r ip; do
                  [ -n "$ip" ] || continue
                  if [ "$pref" -gt "$priority_end" ]; then
                    printf 'adguardvpn-sites: too many resolved addresses, increase priority range\n' >&2
                    exit 1
                  fi
                  ip rule add pref "$pref" to "$ip/32" lookup main
                  add_bypass_v4_route "$ip/32"
                  pref=$((pref + 1))
                done < <(collect_ipv4s "$domain")

                while IFS= read -r ip; do
                  [ -n "$ip" ] || continue
                  if [ "$pref" -gt "$priority_end" ]; then
                    printf 'adguardvpn-sites: too many resolved addresses, increase priority range\n' >&2
                    exit 1
                  fi
                  ip -6 rule add pref "$pref" to "$ip/128" lookup main
                  add_bypass_v6_route "$ip/128"
                  pref=$((pref + 1))
                done < <(collect_ipv6s "$domain")
              done < "$domains_file"

            }

            list_domains() {
              ensure_state_file_readable
              if [ -r "$domains_file" ]; then
                sed '/^[[:space:]]*$/d' "$domains_file"
              fi
            }

            vpn_connected() {
              ip rule show | grep -q "^[[:space:]]*$vpn_rule_priority:"
            }

            print_domain_status() {
              local input="$1"
              local domain
              local configured="no"
              local ip
              local route

              domain="$(normalize_domain "$input")" || {
                printf 'adguardvpn-sites: invalid domain or URL: %s\n' "$input" >&2
                exit 64
              }

              ensure_state_file_readable
              if [ -r "$domains_file" ] && grep -Fxq "$domain" "$domains_file"; then
                configured="yes"
              fi

              printf 'Domain: %s\n' "$domain"
              printf 'Configured in bypass list: %s\n' "$configured"
              printf 'AdGuard VPN connected: %s\n' "$(vpn_connected && printf yes || printf no)"

              printf 'IPv4:\n'
              while IFS= read -r ip; do
                [ -n "$ip" ] || continue
                route="$(ip route get "$ip" 2>/dev/null | head -n1 || true)"
                if printf '%s\n' "$route" | grep -q ' dev tun0 '; then
                  printf '  %s -> VPN (%s)\n' "$ip" "$route"
                else
                  printf '  %s -> bypass (%s)\n' "$ip" "$route"
                fi
              done < <(collect_ipv4s "$domain")

              printf 'IPv6:\n'
              while IFS= read -r ip; do
                [ -n "$ip" ] || continue
                route="$(ip -6 route get "$ip" 2>/dev/null | head -n1 || true)"
                if printf '%s\n' "$route" | grep -q ' dev tun0 '; then
                  printf '  %s -> VPN (%s)\n' "$ip" "$route"
                else
                  printf '  %s -> bypass (%s)\n' "$ip" "$route"
                fi
              done < <(collect_ipv6s "$domain")
            }

            if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
              usage
              exit 64
            fi

            command="$1"

            case "$command" in
              --apply-now)
                [ "$#" -eq 1 ] || { usage; exit 64; }
                need_root "$@"
                apply_rules
                exit 0
                ;;
              add)
                [ "$#" -eq 2 ] || { usage; exit 64; }
                need_root "$@"
                ensure_state_dir
                domain="$(normalize_domain "$2")" || {
                  printf 'adguardvpn-sites: invalid domain or URL: %s\n' "$2" >&2
                  exit 64
                }
                if ! grep -Fxq "$domain" "$domains_file"; then
                  printf '%s\n' "$domain" >> "$domains_file"
                  sort -u -o "$domains_file" "$domains_file"
                fi
                apply_rules
                printf 'Added VPN bypass domain: %s\n' "$domain"
                ;;
              remove)
                [ "$#" -eq 2 ] || { usage; exit 64; }
                need_root "$@"
                ensure_state_dir
                domain="$(normalize_domain "$2")" || {
                  printf 'adguardvpn-sites: invalid domain or URL: %s\n' "$2" >&2
                  exit 64
                }
                grep -Fxv "$domain" "$domains_file" > "$domains_file.tmp" || true
                mv "$domains_file.tmp" "$domains_file"
                apply_rules
                printf 'Removed VPN bypass domain: %s\n' "$domain"
                ;;
              list)
                [ "$#" -eq 1 ] || { usage; exit 64; }
                list_domains
                ;;
              status)
                case "$#" in
                  1)
                    printf 'Configured domains:\n'
                    list_domains || true
                    printf 'AdGuard VPN connected: %s\n' "$(vpn_connected && printf yes || printf no)"
                    ;;
                  2)
                    print_domain_status "$2"
                    ;;
                  *)
                    usage
                    exit 64
                    ;;
                esac
                ;;
              clear)
                [ "$#" -eq 1 ] || { usage; exit 64; }
                need_root "$@"
                ensure_state_dir
                : > "$domains_file"
                apply_rules
                printf 'Cleared VPN bypass domain list\n'
                ;;
              *)
                usage
                exit 64
                ;;
            esac
    '';
  };

  adguardvpnExclude = pkgs.writeShellApplication {
    name = "adguardvpn-exclude";
    runtimeInputs = [ adguardvpnBypass ];
    text = ''
      exec adguardvpn-sites add "$@"
    '';
  };

  adguardvpnZshCompletion = pkgs.writeTextDir "share/zsh/site-functions/_adguardvpn-cli" ''
    #compdef adguardvpn-cli

    local -a commands common_opts
    common_opts=(
      '(-h --help)'{-h,--help}'[show help]'
      '--help-all[show full help]'
    )
    commands=(
      'login:sign in to AdGuard VPN'
      'logout:sign out from AdGuard VPN'
      'list-locations:list VPN locations'
      'connect:connect to VPN'
      'disconnect:disconnect from VPN'
      'status:show VPN status'
      'license:show license information'
      'config:manage configuration'
      'check-update:check for updates'
      'export-logs:export logs'
      'update:update AdGuard VPN CLI'
      'site-exclusions:manage site exclusions'
    )

    _adguardvpn_locations() {
      local -a locations
      local output
      output="$(adguardvpn-cli list-locations --bash-completion "$PREFIX" 2>/dev/null)" || return
      locations=("''${(@f)output}")
      _describe -t locations 'location' locations
    }

    _arguments -C \
      $common_opts \
      '(-v --version)'{-v,--version}'[show version]' \
      '1:command:->command' \
      '*::argument:->argument' && return

    case $state in
      command)
        _describe -t commands 'adguardvpn-cli command' commands
        ;;
      argument)
        case $words[1] in
          login)
            _arguments \
              $common_opts \
              '(-u --username)'{-u,--username}'[username]:username:' \
              '(-p --password)'{-p,--password}'[password]:password:'
            ;;
          connect)
            _arguments \
              $common_opts \
              '(-f --fastest)'{-f,--fastest}'[connect to fastest location]' \
              '(-v --verbose)'{-v,--verbose}'[verbose output]' \
              '--no-fork[do not fork to background]' \
              '--ppid-file[parent pid file]:file:_files' \
              '--pid-file[pid file]:file:_files' \
              '(-l --location)'{-l,--location}'[location]:location:_adguardvpn_locations' \
              '(-4 --ipv4only)'{-4,--ipv4only}'[use IPv4 only]' \
              '(-6 --ipv6only)'{-6,--ipv6only}'[use IPv6 only]' \
              '(-y --yes)'{-y,--yes}'[answer yes]' \
              '--log-to-file[write log to file]' \
              '--no-progress[hide progress]' \
              '--boot[start during boot]'
            ;;
          update)
            _arguments \
              $common_opts \
              '(-y --yes)'{-y,--yes}'[answer yes]' \
              '(-v --verbose)'{-v,--verbose}'[verbose output]'
            ;;
          config)
            _arguments \
              $common_opts \
              '1:config command:(set-mode set-dns set-socks-port set-socks-host set-socks-username set-socks-password clear-socks-auth set-change-system-dns set-tun-routing-mode create-route-script set-crash-reporting set-telemetry set-update-channel set-protocol set-post-quantum set-show-hints set-debug-logging set-show-notifications set-bound-if-override show)' \
              '*:value:->config_value'

            case $state in
              config_value)
                case $words[2] in
                  set-mode) _values mode socks tun ;;
                  set-dns) _values dns default ;;
                  set-change-system-dns|set-crash-reporting|set-show-hints|set-debug-logging|set-protocol|set-post-quantum|set-show-notifications) _values state on off ;;
                  set-tun-routing-mode) _values routing-mode auto script none ;;
                  set-update-channel) _values update-channel beta nightly release ;;
                esac
                ;;
            esac
            ;;
          site-exclusions)
            _arguments \
              $common_opts \
              '1:site-exclusions command:(add remove show clear mode)' \
              '--for-mode[mode]:mode:(general selective)' \
              '*:domain:'
            ;;
          *)
            _arguments $common_opts
            ;;
        esac
        ;;
    esac
  '';

  yandexDirectRouting = pkgs.writeShellScript "yandex-direct-routing" ''
    set -eu

    priority=30749
    dante_uid="$(${pkgs.coreutils}/bin/id -u dante)"

    ${pkgs.iproute2}/bin/ip -4 rule del pref "$priority" 2>/dev/null || true
    ${pkgs.iproute2}/bin/ip -6 rule del pref "$priority" 2>/dev/null || true

    if [ "''${1:-start}" = start ]; then
      ${pkgs.iproute2}/bin/ip -4 rule add pref "$priority" \
        uidrange "$dante_uid-$dante_uid" lookup main
      ${pkgs.iproute2}/bin/ip -6 rule add pref "$priority" \
        uidrange "$dante_uid-$dante_uid" lookup main
    fi
  '';
in
{
  networking.networkmanager.dns = "dnsmasq";

  # Yandex Browser connects to this loopback-only SOCKS proxy. Connections
  # opened by Dante have their own UID and are routed through the normal main
  # table before AdGuard VPN's catch-all rule at priority 30801.
  services.dante = {
    enable = true;
    config = ''
      internal: 127.0.0.1 port = 1081
      external: wlp2s0
      socksmethod: none
      clientmethod: none

      client pass {
        from: 127.0.0.1/32 to: 0.0.0.0/0
      }

      socks pass {
        from: 127.0.0.1/32 to: 0.0.0.0/0
        command: connect bind udpassociate
      }
    '';
  };

  systemd.services.yandex-direct-routing = {
    description = "Route the Yandex Browser SOCKS proxy outside AdGuard VPN";
    after = [
      "dante.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${yandexDirectRouting} start";
      ExecStop = "${yandexDirectRouting} stop";
    };
  };

  environment.systemPackages = [
    (pkgs.symlinkJoin {
      name = "adguardvpn-tools";
      paths = [
        adguardvpnBypass
        adguardvpnExclude
        adguardvpnZshCompletion
      ];
    })
  ];

  systemd.services.adguardvpn-bypass-refresh = {
    description = "Refresh system-level AdGuard VPN bypass rules";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${adguardvpnBypass}/bin/adguardvpn-sites --apply-now";
      TimeoutStartSec = "5min";
    };
  };

  systemd.timers.adguardvpn-bypass-refresh = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "30min";
      Unit = "adguardvpn-bypass-refresh.service";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/adguardvpn-bypass 0755 root root -"
    "f /var/lib/adguardvpn-bypass/domains 0644 root root -"
  ];

  # Remove state left by the retired country-wide RU bypass implementation.
  system.activationScripts.removeLegacyAdguardVpnRuBypass.text = ''
    rm -f \
      /var/lib/adguardvpn-bypass/ru-enabled \
      /var/lib/adguardvpn-bypass/ru.zone \
      /var/lib/adguardvpn-bypass/ru.zone6
  '';
}
