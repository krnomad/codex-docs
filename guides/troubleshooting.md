# 문제 해결

## 스킬이 보이지 않음

`~/.codex/skills/codex-docs/SKILL.md`가 있는지 확인하고, 설치 후 새 Codex 작업을 시작합니다. 없다면 원본 clone에서 `./install.sh`를 다시 실행합니다.

## AGENTS.md 병합을 거부함

설치기는 `<!-- codex-docs:start -->`와 `<!-- codex-docs:end -->`가 짝이 맞지 않거나 여러 개 있으면 파일을 바꾸지 않습니다. 마커 블록을 하나만 남기거나 제거한 뒤 재실행합니다. 마커 밖의 사용자 지침은 수정하지 마세요.

## 수동 갱신 실패

폐쇄망에서는 정상 동작입니다. `codex-docs update` 실패 후에도 현재 스냅샷은 남습니다. `codex-docs status`로 로컬 문서의 해시와 시각을 확인합니다.

## 문서 검색 결과가 없음

`codex-docs search`에는 짧고 구체적인 영어 용어를 사용합니다. 예: `hooks`, `config.toml`, `AGENTS.md`. 결과가 없으면 로컬 스냅샷에 해당 항목이 없을 수 있으므로 연결 가능한 환경에서 갱신합니다.
