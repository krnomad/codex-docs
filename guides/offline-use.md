# 폐쇄망 사용

폐쇄망에서는 이미 설치된 스냅샷만 사용합니다. 검색은 네트워크를 사용하지 않습니다.

```bash
~/.codex-docs/bin/codex-docs search 'AGENTS.md'
~/.codex-docs/bin/codex-docs status
```

Codex에는 Codex CLI 관련 질문에 먼저 위의 로컬 매뉴얼을 검색하라는 전역 지침과 스킬이 등록됩니다. `status`의 갱신 시각은 스냅샷의 시각이며, 현재 공식 문서의 시각은 아닐 수 있습니다.
