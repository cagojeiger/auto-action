# openclaw-stack

OpenClaw + Browserless (CDP) 번들 Helm chart.

## 설치

```bash
helm repo add auto-action https://cagojeiger.github.io/auto-action
helm repo update
helm install openclaw-stack auto-action/openclaw-stack -f values.yaml
```

기본 values로 설치하면 즉시 동작합니다. 환경별 설정은 values override로 적용하세요.

## 필수 시크릿

`openclaw-secrets` Secret에 `gateway-token` 키가 필수입니다. 추가 시크릿은 `secretEnvVars`로 매핑:

```yaml
openclaw:
  secrets:
    existingSecret: openclaw-secrets
    gatewayTokenKey: gateway-token
    secretEnvVars:
      - name: LITELLM_API_KEY
        key: litellm-api-key
      - name: SLACK_BOT_TOKEN
        key: slack-bot-token
```

## 주요 설정

### Config

`openclaw.config` 블록이 `openclaw.json`으로 렌더링됩니다. Browserless CDP URL은 자동 주입.

```yaml
openclaw:
  config:
    agents:
      defaults:
        model:
          primary: "litellm/gemini/gemini-2.5-flash"
    channels:
      slack:
        dm: { policy: "open", allowFrom: ["*"] }
        replyToMode: "off"
```

기존 ConfigMap 사용: `openclaw.existingConfigMap: "my-configmap"`

### 스케줄링

`nodeSelector`, `tolerations`, `affinity` — openclaw/browserless 각각 지원.

## Slack 연동

### Slack App 설정

1. https://api.slack.com/apps > **Create New App**
2. **Socket Mode** 활성화 → App Token (`xapp-...`) 생성
3. **Bot Token Scopes**: `app_mentions:read`, `chat:write`, `channels:history`, `channels:read`, `groups:history`, `groups:read`, `im:history`, `im:read`, `im:write`, `mpim:history`, `mpim:read`, `users:read`, `reactions:read`, `reactions:write`, `files:read`, `files:write`
4. **Event Subscriptions**: `app_mention`, `message.channels`, `message.groups`, `message.im`, `message.mpim`, `reaction_added`, `reaction_removed`, `member_joined_channel`
5. **App Home**: Messages Tab 체크 + "Allow users to send Slash commands and messages" 체크
6. **Install to Workspace** → Bot Token (`xoxb-...`) 저장

### DM 정책

| 정책 | 동작 |
|------|------|
| `open` + `allowFrom: ["*"]` | 누구나 DM으로 바로 대화 |
| `pairing` | pairing code 승인 필요 |

### 응답 방식 (replyToMode)

| 모드 | 동작 |
|------|------|
| `off` | 대화형 직접 응답 |
| `all` | 항상 쓰레드 |
| `first` | 첫 응답만 쓰레드 |
