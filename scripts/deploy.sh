#!/usr/bin/env bash
set -Eeuo pipefail

LIVE_DIR="${STARKWOLF_LIVE_DIR:-/opt/starkwolf}"
REPO_ROOT="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/.." &&
  pwd
)"

TS="$(date +%Y%m%d-%H%M%S)"
ROLLBACK="${LIVE_DIR}/rollback/git-deploy-${TS}"

echo "===== CONTROLLED STARKWOLF DEPLOYMENT ====="
echo "Source commit: $(git -C "$REPO_ROOT" rev-parse --short HEAD)"
echo "Rollback: $ROLLBACK"

cd "$LIVE_DIR"

docker compose config -q

sudo mkdir -p "$ROLLBACK"
sudo cp -a docker-compose.yml "$ROLLBACK/docker-compose.yml"

echo
echo "Deployment intentionally requires explicit approval."
echo
read -r -p "Type DEPLOY to continue: " approval

if [ "$approval" != "DEPLOY" ]; then
    echo "Deployment cancelled."
    exit 0
fi

sudo cp \
  "$REPO_ROOT/docker/docker-compose.yml" \
  "$LIVE_DIR/docker-compose.yml"

sudo docker compose config -q

sudo docker compose up -d

"$REPO_ROOT/scripts/verify.sh"

echo "PASS: controlled deployment completed"
