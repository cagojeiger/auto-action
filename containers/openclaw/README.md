# OpenClaw Gateway

AI 개인 비서 [OpenClaw](https://github.com/openclaw/openclaw)의 Gateway를 Docker 컨테이너로 실행합니다.

## 빠른 시작

```bash
docker run -d \
  -p 18789:18789 \
  -v openclaw-data:/home/openclaw/.openclaw \
  -e OPENCLAW_GATEWAY_TOKEN=my-secret-token \
  -e ANTHROPIC_API_KEY=sk-ant-... \
  cagojeiger/openclaw:latest
```

http://localhost:18789 에서 Control UI(WebChat)에 접속합니다.

## 환경 변수

| 변수 | 필수 | 설명 |
|---|---|---|
| `OPENCLAW_GATEWAY_TOKEN` | **필수** | Gateway 접속 토큰 (auth mode=token) |
| `ANTHROPIC_API_KEY` | 최소 하나 | Anthropic API 키 |
| `OPENAI_API_KEY` | 최소 하나 | OpenAI API 키 |
| `TELEGRAM_BOT_TOKEN` | 선택 | Telegram 봇 토큰 |
| `DISCORD_BOT_TOKEN` | 선택 | Discord 봇 토큰 |
| `BRAVE_API_KEY` | 선택 | 웹 검색용 Brave API 키 |

## 데이터 볼륨

`/home/openclaw/.openclaw` 하나만 마운트하면 모든 상태가 보존됩니다:

- `openclaw.json` - 메인 설정
- `credentials/` - OAuth 토큰, WhatsApp 크레덴셜
- `agents/` - 에이전트 메모리, 대화 세션 로그
- `devices/` - 디바이스 페어링 정보
- `cron/` - 예약 작업

## Docker Compose

```yaml
services:
  openclaw:
    image: cagojeiger/openclaw:latest
    ports:
      - "18789:18789"
    volumes:
      - openclaw-data:/home/openclaw/.openclaw
    environment:
      - OPENCLAW_GATEWAY_TOKEN=${OPENCLAW_GATEWAY_TOKEN}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
    restart: unless-stopped

volumes:
  openclaw-data:
```

## Kubernetes (PVC)

```yaml
volumeMounts:
  - name: openclaw-data
    mountPath: /home/openclaw/.openclaw
```

## 포트

| 포트 | 설명 |
|---|---|
| 18789 | Gateway (WebSocket + Control UI + WebChat) |

## 지원 아키텍처

- linux/amd64
- linux/arm64
