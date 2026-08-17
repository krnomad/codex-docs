# Codex Docs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an offline Codex CLI documentation mirror that installs a global local-search skill safely.

**Architecture:** A small Bash synchronizer owns the single official manual and its manifest. An installer copies this repository into a private data directory, installs a global skill, and merges only a marked block into global instructions. A dependency-free test script exercises the user-visible contract in isolated temporary homes.

**Tech Stack:** Bash, curl, git, ripgrep, GitHub Actions, Markdown.

## Global Constraints

- Mirror only `https://developers.openai.com/codex/codex-manual.md`.
- Preserve all pre-existing content outside the `codex-docs` markers in global `AGENTS.md`.
- Make local search and status fully offline.
- Bound every network operation; failed updates must retain local docs.
- Use no runtime language dependency beyond standard shell tools, git, curl, and ripgrep.

---

### Task 1: Mirror synchronizer and manifest

**Files:**
- Create: `scripts/sync-docs.sh`
- Create: `docs/manifest.json`
- Create: `tests/test_codex_docs.sh`

**Interfaces:**
- Produces `docs/codex-manual.md` and a JSON manifest with `source_url`, `sha256`, `bytes`, `updated_at`.
- `sync-docs.sh [manual-url]` returns 0 whether the source is unchanged or updated, and nonzero without replacing existing docs for invalid responses.

- [ ] Write tests that serve a valid fixture through a `file://` URL, run the synchronizer, and assert its manifest hash; then supply an HTML fixture and assert the original manual remains unchanged.
- [ ] Run `bash tests/test_codex_docs.sh` and observe the synchronizer contract fail before implementation.
- [ ] Implement bounded curl download, Markdown validation, SHA-256 comparison, atomic replacement, and deterministic manifest generation.
- [ ] Run `bash tests/test_codex_docs.sh` and observe the synchronizer contract pass.
- [ ] Commit the synchronizer and its tests.

### Task 2: Local command and safe installer

**Files:**
- Create: `bin/codex-docs`
- Create: `install.sh`
- Create: `uninstall.sh`
- Create: `skill/codex-docs/SKILL.md`
- Create: `skill/codex-docs/agents/openai.yaml`
- Modify: `tests/test_codex_docs.sh`

**Interfaces:**
- `bin/codex-docs search <terms>` searches `${CODEX_DOCS_HOME}/docs/codex-manual.md`.
- `bin/codex-docs status` prints manifest fields without network access.
- `bin/codex-docs update` uses `git fetch --quiet` and `git merge --ff-only` with a timeout, reporting cache retention on failure.
- `install.sh` installs to `CODEX_DOCS_HOME` and registers `codex-docs` only in the marked `AGENTS.md` block.

- [ ] Add tests proving that install preserves a custom global instruction, installs the skill, replaces an existing marked block, and makes local search/status work.
- [ ] Run the suite and observe failures for missing installer and command behavior.
- [ ] Initialize the skill with the Codex skill tool, write concise local-first instructions, and validate its metadata.
- [ ] Implement the command, installer, and uninstaller with temporary-file atomic writes and idempotent marker replacement.
- [ ] Run the suite and observe all install/search/status behavior pass.
- [ ] Commit the installer, command, skill, and tests.

### Task 3: Scheduled sync and user operations documentation

**Files:**
- Create: `.github/workflows/sync-docs.yml`
- Create: `README.md`
- Create: `guides/installation.md`
- Create: `guides/offline-use.md`
- Create: `guides/manual-update.md`
- Create: `guides/troubleshooting.md`
- Modify: `tests/test_codex_docs.sh`

**Interfaces:**
- The workflow runs at minute 17 every third hour plus manual dispatch and commits only mirror changes.
- Guides accurately document clone/install, offline search, manual update, status checks, and recovery.

- [ ] Add static tests asserting the workflow schedule, `workflow_dispatch`, manual source URL, and required guide files.
- [ ] Run the suite and observe the missing operational artifacts fail.
- [ ] Implement the workflow and Korean guides, including local-agent scheduling as an unverified future experiment rather than a promised feature.
- [ ] Run `bash tests/test_codex_docs.sh`, `bash -n` for all shell scripts, and skill validation; observe success.
- [ ] Commit the workflow and documentation.

### Task 4: Seed the first official snapshot and release verification

**Files:**
- Modify: `docs/codex-manual.md`
- Modify: `docs/manifest.json`
- Modify: `README.md`

**Interfaces:**
- A fresh clone contains a valid locally searchable manual before any network call.

- [ ] Run `scripts/sync-docs.sh` against the official URL.
- [ ] Verify the manifest hash equals `shasum -a 256 docs/codex-manual.md` and that `bin/codex-docs search AGENTS` returns local hits with networking disabled.
- [ ] Run the complete tests and inspect `git diff --check`.
- [ ] Commit the seeded mirror and verified release-ready state.
