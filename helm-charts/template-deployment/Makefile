.PHONY: test install-plugin lint template clean help

# 기본 대상
all: help

# helm-unittest 플러그인 설치 여부 확인 및 설치
install-plugin:
	@echo "헬름 unittest 플러그인 확인 중..."
	@if ! helm plugin list | grep -q unittest; then \
		echo "helm-unittest 플러그인 설치 중..."; \
		helm plugin install https://github.com/quintush/helm-unittest; \
	else \
		echo "helm-unittest 플러그인이 이미 설치되어 있습니다."; \
	fi

# 헬름 차트 린트 검사
lint:
	@echo "헬름 차트 린트 검사 중..."
	helm lint .


# 헬름 차트 테스트 실행
test: install-plugin
	@echo "헬름 차트 테스트 실행 중..."
	helm unittest .

# 도움말
help:
	@echo "사용 가능한 명령어:"
	@echo "  make install-plugin    - helm-unittest 플러그인 설치"
	@echo "  make lint              - 헬름 차트 린트 검사"
	@echo "  make test              - 모든 테스트 실행"
	@echo "  make help              - 도움말 표시"