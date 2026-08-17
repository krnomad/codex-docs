---
name: codex-docs
description: Search the locally mirrored official Codex CLI manual before external sources. Use for Codex CLI setup, configuration, commands, AGENTS.md, skills, plugins, hooks, MCP, troubleshooting, and offline documentation questions.
---

# Local Codex CLI Documentation

1. Run `${CODEX_DOCS_HOME:-$HOME/.codex-docs}/bin/codex-docs search <specific terms>`.
2. Read only the relevant matching portion of `${CODEX_DOCS_HOME:-$HOME/.codex-docs}/docs/codex-manual.md` needed to answer.
3. State when the local snapshot may be stale; run `codex-docs status` for its timestamp.
4. Use external official sources only when the local manual has no relevant result and network access is available.
5. Never claim that `codex-docs update` succeeded without its explicit success output. If it fails, continue from the local cache.
