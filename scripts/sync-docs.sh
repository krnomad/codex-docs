#!/usr/bin/env bash
set -euo pipefail

SOURCE_URL="${1:-https://developers.openai.com/codex/codex-manual.md}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="${DOCS_DIR:-$PROJECT_ROOT/docs}"
MANUAL_PATH="$DOCS_DIR/codex-manual.md"
MANIFEST_PATH="$DOCS_DIR/manifest.json"
TMP_FILE="$(mktemp "${TMPDIR:-/tmp}/codex-docs-manual.XXXXXX")"
trap 'rm -f "$TMP_FILE"' EXIT

sha256() { shasum -a 256 "$1" | awk '{print $1}'; }
json_escape() { sed 's/\\/\\\\/g; s/"/\\"/g'; }

mkdir -p "$DOCS_DIR"
curl --fail --location --silent --show-error --connect-timeout 15 --max-time 90 \
  --retry 2 --retry-delay 2 --output "$TMP_FILE" "$SOURCE_URL"

if [[ ! -s "$TMP_FILE" ]] || head -n 20 "$TMP_FILE" | grep -Eiq '^[[:space:]]*<!doctype html|^[[:space:]]*<html'; then
  echo 'codex-docs: source is empty or HTML, keeping local manual unchanged' >&2
  exit 1
fi
if [[ $(wc -c < "$TMP_FILE" | tr -d ' ') -lt 50 ]]; then
  echo 'codex-docs: source is too short, keeping local manual unchanged' >&2
  exit 1
fi

NEW_HASH="$(sha256 "$TMP_FILE")"
OLD_HASH=""
[[ -f "$MANUAL_PATH" ]] && OLD_HASH="$(sha256 "$MANUAL_PATH")"
if [[ "$NEW_HASH" == "$OLD_HASH" && -f "$MANIFEST_PATH" ]]; then
  echo 'codex-docs: manual unchanged'
  exit 0
fi
if [[ "$NEW_HASH" != "$OLD_HASH" ]]; then
  mv "$TMP_FILE" "$MANUAL_PATH"
  trap - EXIT
  echo 'codex-docs: manual updated'
else
  echo 'codex-docs: manifest repaired'
fi

BYTES="$(wc -c < "$MANUAL_PATH" | tr -d ' ')"
UPDATED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
SOURCE_JSON="$(printf '%s' "$SOURCE_URL" | json_escape)"
MANIFEST_TMP="$(mktemp "$DOCS_DIR/.manifest.XXXXXX")"
cat > "$MANIFEST_TMP" <<EOF
{
  "source_url": "$SOURCE_JSON",
  "sha256": "$NEW_HASH",
  "bytes": $BYTES,
  "updated_at": "$UPDATED_AT"
}
EOF
mv "$MANIFEST_TMP" "$MANIFEST_PATH"
