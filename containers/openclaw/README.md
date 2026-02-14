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

http://localhost:18789 에서 Control UI에 접속합니다.

## 환경 변수

| 변수 | 필수 | 설명 |
|---|---|---|
| `OPENCLAW_GATEWAY_TOKEN` | **필수** | Gateway 접속 토큰 |
| `ANTHROPIC_API_KEY` | | Anthropic API 키 |
| `ANTHROPIC_BASE_URL` | | 커스텀 Anthropic 엔드포인트 |
| `OPENAI_API_KEY` | | OpenAI API 키 |
| `OPENAI_BASE_URL` | | 커스텀 OpenAI 엔드포인트 |
| `OPENROUTER_API_KEY` | | OpenRouter API 키 |
| `GEMINI_API_KEY` | | Google Gemini API 키 |
| `SLACK_BOT_TOKEN` | | Slack 봇 토큰 (`xoxb-...`) |
| `SLACK_APP_TOKEN` | | Slack 앱 토큰 (`xapp-...`) |
| `TELEGRAM_BOT_TOKEN` | | Telegram 봇 토큰 |
| `DISCORD_BOT_TOKEN` | | Discord 봇 토큰 |

AI 프로바이더 키는 최소 하나 필요합니다.

## 데이터

`/home/openclaw/.openclaw`를 마운트하면 설정, 대화 기록, 크레덴셜이 보존됩니다.

## Kubernetes (quick-deploy)

```yaml
apps:
  openclaw:
    enabled: true
    image:
      repository: cagojeiger/openclaw
      tag: "2026.2.9"
    env:
      - name: OPENCLAW_GATEWAY_TOKEN
        valueFrom:
          secretKeyRef:
            name: openclaw-secrets
            key: gateway-token
      - name: ANTHROPIC_API_KEY
        valueFrom:
          secretKeyRef:
            name: openclaw-secrets
            key: anthropic-api-key
    service:
      enabled: true
      port: 18789
      targetPort: 18789
    persistence:
      enabled: true
      mountPath: /home/openclaw/.openclaw
      size: 5Gi
```

## 사전 설치된 도구

`git`, `gh`, `curl`, `jq`, `python3`, `ripgrep`, `ffmpeg`, `imagemagick`, `pandoc`, `poppler-utils`, `unzip`, `zip`, `openssh-client`
