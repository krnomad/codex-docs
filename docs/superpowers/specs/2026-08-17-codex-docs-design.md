# Codex Docs Design

## Goal

Provide a GitHub-hosted, offline-capable mirror of the official Codex CLI manual. A user can clone this repository and run one installer to add a global `codex-docs` skill and a narrowly managed global `AGENTS.md` rule.

## Source and synchronization

- Source: `https://developers.openai.com/codex/codex-manual.md`.
- GitHub Actions runs every three hours and on `workflow_dispatch`.
- `scripts/sync-docs.sh` downloads the source with bounded curl timeouts, rejects empty or HTML responses, computes SHA-256, and only replaces `docs/codex-manual.md` when content changes.
- `docs/manifest.json` records the source URL, hash, byte count, and UTC update time. The workflow commits only changed mirror files.
- A future local-agent scheduled-download experiment is explicitly out of scope. The installed tool never requires it.

## Installed layout and integration

- The installer copies a repository clone into `~/.codex-docs` by default. `CODEX_DOCS_HOME` overrides this location for tests or advanced users.
- The source skill is `skill/codex-docs`; the installer copies it into `${CODEX_HOME:-$HOME/.codex}/skills/codex-docs`.
- The installer adds only the content between `<!-- codex-docs:start -->` and `<!-- codex-docs:end -->` to `${CODEX_HOME:-$HOME/.codex}/AGENTS.md`. Re-running replaces that block; unrelated instructions remain byte-for-byte unchanged.
- The installed command is `${CODEX_DOCS_HOME}/bin/codex-docs` and supports `search`, `status`, and `update`.

## Offline behavior

- `search <terms>` uses local `rg` against the mirrored manual and succeeds without network access.
- The skill directs Codex to use `search` and targeted local reads before any external documentation route for Codex CLI questions.
- `status` is local-only and reports the manifest metadata.
- `update` performs a bounded `git fetch` and fast-forward-only pull. A network or GitHub failure leaves the existing checkout and docs untouched, returning a nonzero status with an offline-cache message.

## User documentation

The repository contains four Korean operation guides: installation, offline use, manual update, and troubleshooting. The README provides the minimal clone-and-install path and links to those guides.

## Verification

A dependency-free Bash test suite uses a temporary home directory to verify: safe `AGENTS.md` block installation and replacement, skill installation, local search, local status, and an offline `update` failure that preserves the checked-out documentation.

## Non-goals

- Mirroring all OpenAI developer documentation or non-CLI product pages.
- Automatically editing global `config.toml`, installing MCP servers, or scheduling local agents.
- Replacing user-authored global guidance or skills.
