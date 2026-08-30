#!/bin/bash
#
# check-updates.sh
#
# Daily update visibility for Starkwolf containers.
# Does NOT apply updates.
#
# Policy:
# - Generic containers: compare running image ID with configured registry tag.
# - Immich: treat server + ML + database + cache as one coordinated stack.
#   Detect new Immich releases through the official GitHub releases API.
#   Do NOT independently recommend PostgreSQL or Valkey upgrades.
#
# Notification deduplication:
# - New update state       -> send one email and remember it
# - Same unresolved state -> do not email again
# - Update state changes  -> send a new email
# - Everything up to date -> clear remembered state

set -euo pipefail

ENV_FILE="/opt/starkwolf/.env"
STATE_FILE="/opt/starkwolf/.update-check-state"

SMTP_TO=$(grep -E '^SMTP_TO=' "$ENV_FILE" | cut -d '=' -f2-)
SMTP_USER=$(grep -E '^SMTP_USER=' "$ENV_FILE" | cut -d '=' -f2-)

CONTAINERS=(
  jellyfin
  caddy
  navidrome
  pihole
  vaultwarden
)

REPORT=""
UPDATE_STATE=""
UPDATES_FOUND=0
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

#
# IMMICH COORDINATED RELEASE CHECK
#

IMMICH_SERVER_VERSION=$(
  docker inspect immich-server \
    --format '{{index .Config.Labels "org.opencontainers.image.version"}}' \
    2>/dev/null || true
)

IMMICH_ML_VERSION=$(
  docker inspect immich-machine-learning \
    --format '{{index .Config.Labels "org.opencontainers.image.version"}}' \
    2>/dev/null || true
)

IMMICH_LATEST=""

if IMMICH_JSON=$(
  curl -fsSL \
    --max-time 15 \
    -H 'Accept: application/vnd.github+json' \
    https://api.github.com/repos/immich-app/immich/releases/latest \
    2>/dev/null
); then

  IMMICH_LATEST=$(
    printf '%s' "$IMMICH_JSON" |
      python3 -c '
import json
import sys

try:
    data = json.load(sys.stdin)

    if data.get("draft") is True:
        raise ValueError("latest release is draft")

    if data.get("prerelease") is True:
        raise ValueError("latest release is prerelease")

    tag = data.get("tag_name")

    if not tag:
        raise ValueError("tag_name missing")

    print(tag)

except Exception:
    sys.exit(1)
' 2>/dev/null || true
  )
fi

if [ -z "$IMMICH_SERVER_VERSION" ] || [ -z "$IMMICH_ML_VERSION" ]; then

  REPORT+="WARNING  immich: could not determine server and/or machine-learning version\n"

elif [ "$IMMICH_SERVER_VERSION" != "$IMMICH_ML_VERSION" ]; then

  REPORT+="ATTENTION  immich: component version mismatch (server=${IMMICH_SERVER_VERSION}, machine-learning=${IMMICH_ML_VERSION})\n"

  UPDATE_STATE+="immich|component-mismatch|${IMMICH_SERVER_VERSION}|${IMMICH_ML_VERSION}"$'\n'
  UPDATES_FOUND=1

elif [ -z "$IMMICH_LATEST" ]; then

  REPORT+="WARNING  immich (${IMMICH_SERVER_VERSION}): could not determine latest stable upstream release\n"

elif [ "$IMMICH_SERVER_VERSION" != "$IMMICH_LATEST" ]; then

  REPORT+="UPDATE AVAILABLE  immich coordinated stack (${IMMICH_SERVER_VERSION} -> ${IMMICH_LATEST})\n"

  UPDATE_STATE+="immich|${IMMICH_SERVER_VERSION}|${IMMICH_LATEST}"$'\n'
  UPDATES_FOUND=1

else

  REPORT+="OK  immich coordinated stack (${IMMICH_SERVER_VERSION}): latest stable release\n"

fi

REPORT+="POLICY  immich-postgres: dependency managed with Immich release, independent pull check skipped\n"
REPORT+="POLICY  immich-redis: Valkey dependency managed with Immich release, independent pull check skipped\n"

#
# GENERIC CONTAINER IMAGE CHECKS
#

for name in "${CONTAINERS[@]}"; do

  if ! docker inspect "$name" >/dev/null 2>&1; then
    REPORT+="WARNING  ${name}: container not found, skipping\n"
    continue
  fi

  image=$(docker inspect --format '{{.Config.Image}}' "$name")

  if [ "$image" = "caddy-duckdns:local" ]; then
    REPORT+="LOCAL  ${name} (${image}): custom local image, registry update check skipped\n"
    continue
  fi

  running_image_id=$(
    docker inspect --format '{{.Image}}' "$name" 2>/dev/null || echo "unknown"
  )

  if ! docker pull -q "$image" >/dev/null 2>&1; then
    REPORT+="WARNING  ${name} (${image}): pull failed, skipping check\n"
    continue
  fi

  latest_image_id=$(
    docker inspect --format '{{.Id}}' "$image" 2>/dev/null || echo "unknown"
  )

  if [ "$running_image_id" = "unknown" ] || [ "$latest_image_id" = "unknown" ]; then

    REPORT+="UNKNOWN  ${name} (${image}): could not determine image id, check manually\n"

  elif [ "$running_image_id" != "$latest_image_id" ]; then

    REPORT+="UPDATE AVAILABLE  ${name} (${image})\n"

    UPDATE_STATE+="${name}|${image}|${running_image_id}|${latest_image_id}"$'\n'
    UPDATES_FOUND=1

  else

    REPORT+="OK  ${name} (${image}): up to date\n"

  fi

done

#
# NOTIFICATION / DEDUPLICATION
#

if [ "$UPDATES_FOUND" -eq 1 ]; then

  CURRENT_STATE_HASH=$(
    printf '%s' "$UPDATE_STATE" | sha256sum | awk '{print $1}'
  )

  PREVIOUS_STATE_HASH=""

  if [ -f "$STATE_FILE" ]; then
    PREVIOUS_STATE_HASH=$(cat "$STATE_FILE")
  fi

  if [ "$CURRENT_STATE_HASH" = "$PREVIOUS_STATE_HASH" ]; then

    echo "[${TIMESTAMP}] Same unresolved container update state. No duplicate email sent."

  else

    {
      echo "Subject: starkwolf: container updates available"
      echo "To: ${SMTP_TO}"
      echo ""
      echo "Update check run at: ${TIMESTAMP}"
      echo ""
      echo -e "$REPORT"
      echo ""
      echo "No backup or container update was performed automatically."
      echo ""
      echo "Manual update procedure:"
      echo "1. Run /opt/starkwolf/backup-stack.sh"
      echo "2. Confirm backup completed successfully"
      echo "3. Update only the intended container or coordinated stack"
      echo "4. Verify container health after update"
    } | msmtp "${SMTP_TO}"

    printf '%s\n' "$CURRENT_STATE_HASH" > "$STATE_FILE"
    chmod 600 "$STATE_FILE"

    echo "[${TIMESTAMP}] New update state found. Email sent. State recorded."

  fi

else

  rm -f "$STATE_FILE"

  echo "[${TIMESTAMP}] All containers up to date. No email sent. Update state cleared."

fi
