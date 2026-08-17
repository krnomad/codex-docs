#!/usr/bin/env bash
set -euo pipefail

CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"
AGENTS_FILE="$CODEX_DIR/AGENTS.md"
SKILL_DEST="$CODEX_DIR/skills/codex-docs"
START_MARKER='<!-- codex-docs:start -->'
END_MARKER='<!-- codex-docs:end -->'

if [[ -f "$AGENTS_FILE" ]]; then
  start_count="$(grep -Fxc "$START_MARKER" "$AGENTS_FILE" || true)"
  end_count="$(grep -Fxc "$END_MARKER" "$AGENTS_FILE" || true)"
  if [[ "$start_count" != "$end_count" || "$start_count" -gt 1 ]]; then
    echo "codex-docs: refusing to modify malformed markers in $AGENTS_FILE" >&2; exit 1
  fi
  temp_file="$(mktemp "$(dirname "$AGENTS_FILE")/.agents.XXXXXX")"
  awk -v start="$START_MARKER" -v end="$END_MARKER" '
    $0 == start { inside = 1; next }
    $0 == end { inside = 0; next }
    !inside { print }
  ' "$AGENTS_FILE" > "$temp_file"
  mv "$temp_file" "$AGENTS_FILE"
fi
if [[ -d "$SKILL_DEST" ]]; then
  mv "$SKILL_DEST" "$SKILL_DEST.removed.$(date +%Y%m%d%H%M%S)"
fi
echo 'codex-docs: global guidance removed; installation directory retained at ~/.codex-docs'
