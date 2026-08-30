#!/usr/bin/env bash
set -Eeuo pipefail

BACKUP_DIR="/opt/starkwolf/backups"
OUT_DIR="/opt/starkwolf/monitoring/node-exporter/textfile"
OUT="$OUT_DIR/starkwolf_backup.prom"
TMP="$OUT.tmp"

mkdir -p "$OUT_DIR"

LATEST="$(
    find "$BACKUP_DIR" \
      -maxdepth 1 \
      -type f \
      -name 'starkwolf-backup-*.tar.gz.gpg' \
      -printf '%T@ %p\n' 2>/dev/null |
    sort -nr |
    head -n1 || true
)"

if [ -z "$LATEST" ]; then
    {
        echo '# HELP starkwolf_backup_present Whether an encrypted Starkwolf backup exists.'
        echo '# TYPE starkwolf_backup_present gauge'
        echo 'starkwolf_backup_present 0'
    } > "$TMP"
else
    MTIME="${LATEST%% *}"
    MTIME="${MTIME%.*}"
    FILE="${LATEST#* }"
    SIZE="$(stat -c '%s' "$FILE")"

    {
        echo '# HELP starkwolf_backup_present Whether an encrypted Starkwolf backup exists.'
        echo '# TYPE starkwolf_backup_present gauge'
        echo 'starkwolf_backup_present 1'
        echo
        echo '# HELP starkwolf_backup_last_success_unixtime Timestamp of newest encrypted backup.'
        echo '# TYPE starkwolf_backup_last_success_unixtime gauge'
        echo "starkwolf_backup_last_success_unixtime $MTIME"
        echo
        echo '# HELP starkwolf_backup_latest_size_bytes Size of newest encrypted backup.'
        echo '# TYPE starkwolf_backup_latest_size_bytes gauge'
        echo "starkwolf_backup_latest_size_bytes $SIZE"
    } > "$TMP"
fi

chmod 0644 "$TMP"
mv "$TMP" "$OUT"
