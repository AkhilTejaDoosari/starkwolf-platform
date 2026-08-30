#!/usr/bin/env bash
set -Eeuo pipefail

LIVE_DIR="${STARKWOLF_LIVE_DIR:-/opt/starkwolf}"
cd "$LIVE_DIR"

echo "===== STARKWOLF DEPLOYMENT VERIFICATION ====="

sudo docker compose config -q
echo "PASS: Compose valid"

EXPECTED=(
  alertmanager
  blackbox-exporter
  cadvisor
  caddy
  grafana
  immich-machine-learning
  immich-postgres
  immich-redis
  immich-server
  jellyfin
  navidrome
  node-exporter
  pihole
  prometheus
  vaultwarden
)

mapfile -t EXPECTED_SORTED < <(
  printf '%s\n' "${EXPECTED[@]}" | sort
)

mapfile -t CONFIGURED < <(
  sudo docker compose config --services | sort
)

mapfile -t RUNNING < <(
  sudo docker compose ps --services --filter status=running | sort
)

if ! diff -u \
  <(printf '%s\n' "${EXPECTED_SORTED[@]}") \
  <(printf '%s\n' "${CONFIGURED[@]}"); then
  echo "FAIL: Compose architecture differs from frozen 15-service design"
  exit 1
fi

echo "PASS: exact 15-service Compose architecture"

if ! diff -u \
  <(printf '%s\n' "${EXPECTED_SORTED[@]}") \
  <(printf '%s\n' "${RUNNING[@]}"); then
  echo "FAIL: one or more expected Starkwolf services are not running"
  exit 1
fi

echo "PASS: all 15 expected services running"

FAILED_UNITS="$(
  systemctl --failed --no-legend --plain 2>/dev/null |
  awk 'NF {n++} END {print n+0}'
)"

if [ "$FAILED_UNITS" -ne 0 ]; then
  echo "FAIL: $FAILED_UNITS failed systemd unit(s)"
  systemctl --failed --no-pager || true
  exit 1
fi

echo "PASS: zero failed systemd units"
echo "===== VERIFICATION PASSED ====="
