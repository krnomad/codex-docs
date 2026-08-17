#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${CODEX_DOCS_HOME:-$HOME/.codex-docs}"
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"
AGENTS_FILE="$CODEX_DIR/AGENTS.md"
SKILL_DEST="$CODEX_DIR/skills/codex-docs"
START_MARKER='<!-- codex-docs:start -->'
END_MARKER='<!-- codex-docs:end -->'

[[ "${1:-}" != '--help' ]] || { echo 'Usage: ./install.sh'; exit 0; }
[[ -f "$SOURCE_DIR/docs/codex-manual.md" && -f "$SOURCE_DIR/docs/manifest.json" ]] || {
  echo 'codex-docs: documentation snapshot is missing; run scripts/sync-docs.sh first' >&2; exit 1;
}

backup_path() {
  local path="$1"
  [[ -e "$path" ]] || return 0
  mv "$path" "$path.previous.$(date +%Y%m%d%H%M%S)"
}

mkdir -p "$(dirname "$INSTALL_DIR")" "$CODEX_DIR/skills"
if [[ "$SOURCE_DIR" != "$INSTALL_DIR" ]]; then
  stage="$(mktemp -d "$(dirname "$INSTALL_DIR")/.codex-docs-stage.XXXXXX")"
  trap 'rm -rf "$stage"' EXIT
  cp -R "$SOURCE_DIR/." "$stage/"
  backup_path "$INSTALL_DIR"
  mv "$stage" "$INSTALL_DIR"
  trap - EXIT
fi
backup_path "$SKILL_DEST"
cp -R "$INSTALL_DIR/skill/codex-docs" "$SKILL_DEST"
chmod +x "$INSTALL_DIR/bin/codex-docs" "$INSTALL_DIR/scripts/sync-docs.sh"

mkdir -p "$(dirname "$AGENTS_FILE")"
touch "$AGENTS_FILE"
start_count="$(grep -Fxc "$START_MARKER" "$AGENTS_FILE" || true)"
end_count="$(grep -Fxc "$END_MARKER" "$AGENTS_FILE" || true)"
if [[ "$start_count" != "$end_count" || "$start_count" -gt 1 ]]; then
  echo "codex-docs: refusing to modify malformed markers in $AGENTS_FILE" >&2; exit 1
fi
block_file="$(mktemp "${TMPDIR:-/tmp}/codex-docs-agents-block.XXXXXX")"
output_file="$(mktemp "$(dirname "$AGENTS_FILE")/.agents.XXXXXX")"
trap 'rm -f "$block_file" "$output_file"' EXIT
cat > "$block_file" <<EOF
$START_MARKER
## Local Codex CLI documentation

For Codex CLI setup, configuration, skills, plugins, hooks, MCP, commands, or troubleshooting questions, search the local official manual before using web sources:

\`$INSTALL_DIR/bin/codex-docs search <terms>\`

Read only the relevant matching lines from \`$INSTALL_DIR/docs/codex-manual.md\`. The local snapshot is the offline fallback; use \`$INSTALL_DIR/bin/codex-docs status\` to report its version and \`$INSTALL_DIR/bin/codex-docs update\` only when GitHub is reachable.
$END_MARKER
EOF
awk -v start="$START_MARKER" -v end="$END_MARKER" -v block="$block_file" '
  BEGIN { while ((getline line < block) > 0) replacement = replacement line "\n"; close(block) }
  $0 == start { if (!inserted) { printf "%s", replacement; inserted = 1 }; inside = 1; next }
  $0 == end { inside = 0; next }
  !inside { print }
  END { if (!inserted) { if (NR > 0) print ""; printf "%s", replacement } }
' "$AGENTS_FILE" > "$output_file"
mv "$output_file" "$AGENTS_FILE"
trap - EXIT
echo "codex-docs: installed at $INSTALL_DIR"
echo "codex-docs: skill installed at $SKILL_DEST"
