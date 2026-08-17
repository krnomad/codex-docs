# Codex Docs

폐쇄망에서도 사용할 수 있도록 공식 Codex CLI 매뉴얼을 로컬에 보관하고, Codex가 이를 먼저 검색하도록 전역 스킬과 `AGENTS.md` 규칙을 설치합니다.

```bash
git clone <YOUR-REPOSITORY-URL> codex-docs
cd codex-docs
./install.sh
```

설치 후:

```bash
~/.codex-docs/bin/codex-docs search 'config.toml'
~/.codex-docs/bin/codex-docs status
~/.codex-docs/bin/codex-docs update
```

GitHub Actions는 [공식 Codex CLI 매뉴얼](https://developers.openai.com/codex/codex-manual.md)을 3시간마다 확인하고 변경됐을 때만 스냅샷을 커밋합니다. GitHub Actions의 수동 실행도 지원합니다.

운영 가이드:

- [설치](guides/installation.md)
- [폐쇄망 사용](guides/offline-use.md)
- [수동 갱신](guides/manual-update.md)
- [문제 해결](guides/troubleshooting.md)

로컬 에이전트가 주기적으로 직접 내려받는 방식은 별도 검증 대상이며, 현재 기본 동기화 경로는 GitHub Actions입니다.
