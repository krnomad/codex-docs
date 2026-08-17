#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local needle="$1"
  local file="$2"
  grep -Fq -- "$needle" "$file" || fail "expected '$needle' in $file"
}

assert_same_file() {
  cmp -s "$1" "$2" || fail "expected $1 and $2 to match"
}

test_sync_rejects_invalid_response_without_replacing_manual() {
  local docs_dir="$TMP_ROOT/sync/docs"
  local valid="$TMP_ROOT/valid.md"
  local invalid="$TMP_ROOT/invalid.html"
  mkdir -p "$docs_dir"
  {
    printf '# Codex CLI\n\nLocal fixture with enough Markdown content for validation.\n'
    for _ in {1..20}; do printf 'ordinary Markdown line\n'; done
    printf '<html>code example</html>\n'
  } > "$valid"
  printf '<!DOCTYPE html><html><body>blocked</body></html>\n' > "$invalid"

  DOCS_DIR="$docs_dir" "$ROOT/scripts/sync-docs.sh" "file://$valid"
  assert_contains 'Codex CLI' "$docs_dir/codex-manual.md"
  cp "$docs_dir/manifest.json" "$TMP_ROOT/manifest-before-second-sync.json"
  sleep 1
  DOCS_DIR="$docs_dir" "$ROOT/scripts/sync-docs.sh" "file://$valid"
  assert_same_file "$TMP_ROOT/manifest-before-second-sync.json" "$docs_dir/manifest.json"
  cp "$docs_dir/codex-manual.md" "$TMP_ROOT/original.md"
  if DOCS_DIR="$docs_dir" "$ROOT/scripts/sync-docs.sh" "file://$invalid"; then
    fail 'invalid HTML response was accepted'
  fi
  assert_same_file "$TMP_ROOT/original.md" "$docs_dir/codex-manual.md"
}

test_install_preserves_global_guidance_and_supports_offline_search() {
  local home_dir="$TMP_ROOT/home"
  local codex_home="$home_dir/.codex"
  local install_dir="$home_dir/.codex-docs"
  local agents_file="$codex_home/AGENTS.md"
  mkdir -p "$codex_home"
  printf '# My global guidance\n\nKeep this line.\n' > "$agents_file"

  CODEX_HOME="$codex_home" CODEX_DOCS_HOME="$install_dir" "$ROOT/install.sh"
  assert_contains 'Keep this line.' "$agents_file"
  assert_contains '<!-- codex-docs:start -->' "$agents_file"
  test -f "$codex_home/skills/codex-docs/SKILL.md" || fail 'skill was not installed'
  awk '
    $0 == "## Local Codex CLI documentation" { print "## Stale managed guidance"; next }
    { print }
  ' "$agents_file" > "$TMP_ROOT/agents-rewrite.md"
  mv "$TMP_ROOT/agents-rewrite.md" "$agents_file"
  CODEX_HOME="$codex_home" CODEX_DOCS_HOME="$install_dir" "$ROOT/install.sh"
  assert_contains '## Local Codex CLI documentation' "$agents_file"
  if grep -Fq '## Stale managed guidance' "$agents_file"; then
    fail 'installer did not replace its managed guidance block'
  fi
  [[ "$(grep -Fxc '<!-- codex-docs:start -->' "$agents_file")" == '1' ]] || fail 'duplicated start marker'

  CODEX_HOME="$codex_home" CODEX_DOCS_HOME="$install_dir" "$install_dir/bin/codex-docs" search AGENTS > "$TMP_ROOT/search.out"
  assert_contains 'AGENTS' "$TMP_ROOT/search.out"
  CODEX_HOME="$codex_home" CODEX_DOCS_HOME="$install_dir" "$install_dir/bin/codex-docs" status > "$TMP_ROOT/status.out"
  assert_contains 'Source:' "$TMP_ROOT/status.out"

  cp "$install_dir/docs/codex-manual.md" "$TMP_ROOT/installed-before-update.md"
  if CODEX_HOME="$codex_home" CODEX_DOCS_HOME="$install_dir" "$install_dir/bin/codex-docs" update > "$TMP_ROOT/update.out" 2>&1; then
    fail 'update unexpectedly succeeded without a configured remote'
  fi
  assert_contains 'local cache retained' "$TMP_ROOT/update.out"
  assert_same_file "$TMP_ROOT/installed-before-update.md" "$install_dir/docs/codex-manual.md"
}

test_operational_artifacts_are_present() {
  assert_contains '17 */3 * * *' "$ROOT/.github/workflows/sync-docs.yml"
  assert_contains 'workflow_dispatch:' "$ROOT/.github/workflows/sync-docs.yml"
  for guide in installation offline-use manual-update troubleshooting; do
    test -s "$ROOT/guides/$guide.md" || fail "missing guide: $guide"
  done
}

test_sync_rejects_invalid_response_without_replacing_manual
test_install_preserves_global_guidance_and_supports_offline_search
test_operational_artifacts_are_present
echo 'PASS: codex-docs'
