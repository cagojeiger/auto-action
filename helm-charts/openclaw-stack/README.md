# openclaw-stack

OpenClaw + Browserless (CDP) 번들 Helm chart.

## 설치

```bash
helm repo add auto-action https://cagojeiger.github.io/auto-action
helm repo update
helm install openclaw-stack auto-action/openclaw-stack -f values.yaml
```

## 필수 시크릿

`openclaw-secrets` Secret에 아래 키가 필요합니다:

| Key | 설명 |
|-----|------|
| `gateway-token` | OpenClaw Gateway 인증 토큰 |
| `litellm-api-key` | LiteLLM API 키 |
| `slack-bot-token` | Slack Bot Token (`xoxb-...`), slack 활성화 시 필요 |
| `slack-app-token` | Slack App Token (`xapp-...`), slack 활성화 시 필요 |

## Slack 연동 설정

### 1. Slack App 생성

1. https://api.slack.com/apps > **Create New App** > **From scratch**
2. **Settings > Socket Mode** > Enable Socket Mode
3. App-Level Token 생성: scope `connections:write` > Generate > `xapp-...` 복사

### 2. Bot Token Scopes 설정

**OAuth & Permissions > Bot Token Scopes**:

- `app_mentions:read`, `chat:write`
- `channels:history`, `channels:read`
- `groups:history`, `im:history`, `mpim:history`
- `users:read`
- `reactions:read`, `reactions:write`
- `files:read`, `files:write`

### 3. Event Subscriptions

**Event Subscriptions > Enable Events > Subscribe to bot events**:

- `app_mention`
- `message.channels`, `message.groups`, `message.im`, `message.mpim`
- `reaction_added`, `reaction_removed`
- `member_joined_channel`

### 4. App Home

**App Home** > Messages Tab 체크

### 5. Workspace에 설치

**Install App** > Install to Workspace > `xoxb-...` Bot Token 복사

### 6. Vault에 토큰 저장

```bash
vault kv put secret/openclaw/credentials \
  gatewayToken="..." \
  litellmApiKey="..." \
  slackBotToken="xoxb-..." \
  slackAppToken="xapp-..."
```

### 7. values.yaml에서 Slack 활성화

```yaml
openclaw:
  slack:
    enabled: true
    dm:
      policy: "open"
    groupPolicy: "open"
```
