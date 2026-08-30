#!/usr/bin/env bash
set -Eeuo pipefail

LIVE_DIR="${STARKWOLF_LIVE_DIR:-/opt/starkwolf}"

cd "$LIVE_DIR"

echo "===== STARKWOLF DEPLOYMENT VERIFICATION ====="

docker compose config -q
echo "PASS: Compose valid"

EXPECTED="${EXPECTED_CONTAINER_COUNT:-15}"

RUNNING="$(
  docker ps --format '{{.Names}}' |
  wc -l |
  tr -d ' '
)"

echo "Running containers: $RUNNING"

if [ "$RUNNING" -ne "$EXPECTED" ]; then
    echo "FAIL: expected $EXPECTED running containers"
    exit 1
fi

echo "PASS: expected container count running"
