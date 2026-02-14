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

**OAuth & Permissions > Bot Token Scopes**에 아래 scope **모두** 추가:

| Scope | 용도 |
|-------|------|
| `app_mentions:read` | @멘션 감지 |
| `chat:write` | 메시지 전송 |
| `channels:history` | 공개 채널 메시지 읽기 |
| `channels:read` | 공개 채널 목록 조회 |
| `groups:history` | 프라이빗 채널 메시지 읽기 |
| `groups:read` | 프라이빗 채널 목록 조회 |
| `im:history` | DM 메시지 읽기 |
| `im:read` | DM 대화 목록 조회 |
| `im:write` | DM 대화 시작 |
| `mpim:history` | 그룹 DM 메시지 읽기 |
| `mpim:read` | 그룹 DM 목록 조회 |
| `users:read` | 사용자 정보 조회 |
| `reactions:read` | 리액션 읽기 |
| `reactions:write` | 리액션 쓰기 |
| `files:read` | 파일 읽기 |
| `files:write` | 파일 업로드 |

> Scope 추가 후 반드시 **Reinstall to Workspace** 필요 (새 Bot Token 발급됨).
> 새 Bot Token을 Vault에 다시 저장해야 합니다.

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
2. **Show Tabs > Messages Tab** 체크
3. **Allow users to send Slash commands and messages from the messages tab** 체크

> 3번이 체크 안 되어 있으면 봇에게 DM 입력창이 나타나지 않습니다.

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
      policy: "open"       # DM 정책: "open" (누구나) 또는 "pairing" (pairing code 필요)
      allowFrom: '["*"]'   # policy가 "open"일 때 필수 — 허용 대상 ("*" = 모든 사용자)
    replyToMode: "off"     # 응답 방식: "off" (대화형), "all" (항상 쓰레드), "first" (첫 응답만 쓰레드)
    groupPolicy: "open"    # 채널 정책: "open" (모든 채널) 또는 채널별 제한
```

### DM 정책 (dm.policy)

| 정책 | 동작 | allowFrom |
|------|------|-----------|
| `open` | 누구나 DM으로 바로 대화 가능 | **필수** — `'["*"]'` 또는 특정 사용자 목록 |
| `pairing` | DM 시 pairing code 생성 → 관리자 승인 필요 | 불필요 |

> **주의**: `dm.policy: "open"`인데 `allowFrom`이 없으면 validation 에러가 발생합니다.
>
> `pairing` 모드에서는 사용자가 DM을 보내면 pairing code가 생성되고, `openclaw pairing list slack` → `openclaw pairing approve slack <CODE>`로 승인해야 대화가 시작됩니다.

### 응답 방식 (replyToMode)

| 모드 | 동작 |
|------|------|
| `off` | DM/채널에 직접 응답 (대화하듯이) — 이미 쓰레드 안에 있으면 쓰레드 유지 |
| `all` | 모든 응답을 쓰레드로 생성 (기본값 변경 전 OpenClaw 기본 동작) |
| `first` | 첫 응답만 쓰레드, 이후 응답은 채널에 직접 |
