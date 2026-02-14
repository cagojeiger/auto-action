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
2. App 이름과 Workspace 선택

### 2. Socket Mode 활성화

1. 왼쪽 메뉴 **Settings > Socket Mode** > **Enable Socket Mode**
2. App-Level Token 생성 화면이 나타남:
   - Token Name: `openclaw-socket` (아무 이름)
   - **Add Scope** > `connections:write` 추가
   - **Generate** 클릭
   - `xapp-1-...` 토큰 복사 저장 → 이것이 **App Token**

> Socket Mode를 활성화해야 App-Level Token 생성 섹션이 나타납니다.
> 나중에 다시 확인: **Settings > Basic Information > App-Level Tokens** 섹션

### 3. Bot Token Scopes 설정

**OAuth & Permissions > Bot Token Scopes**에 아래 scope 추가:

- `app_mentions:read` — 멘션 감지
- `chat:write` — 메시지 전송
- `channels:history`, `channels:read` — 채널 메시지 읽기
- `groups:history` — 프라이빗 채널 메시지 읽기
- `im:history` — DM 읽기
- `mpim:history` — 그룹 DM 읽기
- `users:read` — 사용자 정보 조회
- `reactions:read`, `reactions:write` — 리액션 읽기/쓰기
- `files:read`, `files:write` — 파일 읽기/쓰기

### 4. Event Subscriptions

1. 왼쪽 메뉴 **Event Subscriptions** > **Enable Events** 토글 ON
2. **Subscribe to bot events**에 아래 이벤트 추가:
   - `app_mention` — @멘션 시 반응
   - `message.channels` — 공개 채널 메시지
   - `message.groups` — 프라이빗 채널 메시지
   - `message.im` — DM 메시지
   - `message.mpim` — 그룹 DM 메시지
   - `reaction_added`, `reaction_removed` — 리액션 이벤트
   - `member_joined_channel` — 채널 참여 이벤트
3. **Save Changes** 클릭

### 5. App Home 설정

1. 왼쪽 메뉴 **App Home**
2. **Show Tabs > Messages Tab** 체크 (DM 지원용)

### 6. Workspace에 설치 (Bot Token 발급)

1. 왼쪽 메뉴 **Install App** (또는 **OAuth & Permissions**)
2. **Install to Workspace** 클릭 > 권한 허용
3. **Bot User OAuth Token** (`xoxb-...`) 복사 저장 → 이것이 **Bot Token**

> Scope 변경 후에는 **Reinstall to Workspace** 필요.
> Bot Token Scopes가 하나 이상 추가되어 있어야 Install 버튼이 활성화됩니다.

### 7. Vault에 토큰 저장

```bash
vault kv put secret/openclaw/credentials \
  gatewayToken="..." \
  litellmApiKey="..." \
  slackBotToken="xoxb-..." \
  slackAppToken="xapp-..."
```

| 토큰 | 형식 | 발급 위치 |
|------|------|-----------|
| Bot Token | `xoxb-...` | OAuth & Permissions > Bot User OAuth Token |
| App Token | `xapp-1-...` | Basic Information > App-Level Tokens |

### 8. values.yaml에서 Slack 활성화

```yaml
openclaw:
  slack:
    enabled: true
    dm:
      policy: "open"     # DM 정책: "open" (누구나) 또는 "pairing" (pairing code 필요)
    groupPolicy: "open"  # 채널 정책: "open" (모든 채널) 또는 채널별 제한
```
