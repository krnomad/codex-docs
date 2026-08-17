# 수동 갱신

GitHub에 연결 가능한 환경에서는 설치본을 수동으로 갱신할 수 있습니다.

```bash
~/.codex-docs/bin/codex-docs update
~/.codex-docs/bin/codex-docs status
```

`update`는 fast-forward 가능한 Git 변경만 적용합니다. GitHub 연결, 원격 저장소, 또는 병합 조건이 없으면 실패하고 기존 로컬 문서는 그대로 남습니다. 설치기나 스킬 자체를 다시 배포하려면 원본 clone에서 최신 변경을 받은 뒤 `./install.sh`를 다시 실행합니다.

GitHub Actions는 3시간마다 공식 원본을 확인하며, Actions 화면의 **Run workflow**로 즉시 실행할 수도 있습니다. 로컬 에이전트의 주기 다운로드는 별도 검증 전까지 지원 기능이 아닙니다.
