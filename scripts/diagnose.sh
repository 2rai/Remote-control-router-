#!/usr/bin/env bash
# Read-only network health check. Safe to run any time: changes nothing.
# Works on Linux and macOS. Usage: ./scripts/diagnose.sh
set -u
cd "$(dirname "$0")/.."
[ -f .env ] && set -a && . ./.env && set +a

os=$(uname -s)
section() { printf '\n=== %s ===\n' "$1"; }

section "Host"
echo "$(hostname) ($os) — $(date)"

section "Default gateway"
if [ "$os" = Darwin ]; then
  gw=$(route -n get default 2>/dev/null | awk '/gateway/{print $2}')
else
  gw=$(ip route 2>/dev/null | awk '/^default/{print $3; exit}')
fi
echo "Detected: ${gw:-none}   Configured ROUTER_IP: ${ROUTER_IP:-unset}"
target=${ROUTER_IP:-$gw}

section "Local addresses"
if [ "$os" = Darwin ]; then ifconfig | awk '/inet /{print $2}'; else ip -brief addr; fi

section "Router reachability ($target)"
ping -c 4 "$target" 2>&1 | tail -2

section "Internet reachability"
for h in 1.1.1.1 8.8.8.8; do printf '%s: ' "$h"; ping -c 3 "$h" 2>&1 | tail -1; done

section "DNS"
for n in google.com cloudflare.com; do
  printf '%s -> ' "$n"
  (command -v dig >/dev/null && dig +short "$n" | head -1) || nslookup "$n" 2>/dev/null | awk '/^Address/{a=$2}END{print a}'
done

section "Public IP"
curl -s --max-time 5 https://api.ipify.org || echo "unavailable"; echo

section "Router admin ports open on $target"
for p in 22 23 80 443 8080 8443; do
  if (command -v nc >/dev/null && nc -z -w 2 "$target" "$p" 2>/dev/null); then echo "  $p open"; fi
done

section "Latency to internet (10 pings)"
ping -c 10 1.1.1.1 2>&1 | tail -1
