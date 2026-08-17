# 설치

연결 가능한 환경에서 저장소를 받습니다.

```bash
git clone <YOUR-REPOSITORY-URL> codex-docs
cd codex-docs
./install.sh
```

설치기는 `~/.codex-docs`에 사본을 두고, `~/.codex/skills/codex-docs`와 관리 블록만 `~/.codex/AGENTS.md`에 추가합니다. 기존 전역 지침은 보존됩니다.

확인:

```bash
~/.codex-docs/bin/codex-docs status
test -f ~/.codex/skills/codex-docs/SKILL.md && echo 'skill installed'
```

새 Codex 작업을 시작하면 전역 지침과 스킬을 발견할 수 있습니다.
