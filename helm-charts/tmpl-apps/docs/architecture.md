# Tmpl Apps 아키텍처

## 개요

Tmpl Apps는 템플릿 엔진, 프로파일 시스템, 자동 연결 엔진을 결합한 고급 헬름 차트입니다.

## 아키텍처 다이어그램

```
┌─────────────────────────────────────────────────────────────┐
│                         values.yaml                          │
├─────────────────────────┬───────────────────────────────────┤
│      Global Config      │           Apps Config             │
│  - domain              │   - frontend                       │
│  - imageRegistry       │   - backend                        │
│  - imagePullSecrets    │   - database                       │
└───────────┬────────────┴────────────┬──────────────────────┘
            │                          │
            ▼                          ▼
┌───────────────────────┐  ┌─────────────────────────────────┐
│   Profile System      │  │      App Definition             │
│  - base               │  │  - name                         │
│  - web                │◄─┤  - profile                      │
│  - api                │  │  - image                        │
│  - worker             │  │  - scale/expose/host            │
│  - database           │  │  - connections                  │
└───────────┬───────────┘  └──────────┬──────────────────────┘
            │                          │
            └──────────┬───────────────┘
                       ▼
            ┌─────────────────────┐
            │   Merge Engine      │
            │  - Profile merge    │
            │  - Inheritance      │
            │  - Overrides        │
            └──────────┬──────────┘
                       ▼
         ┌─────────────────────────────┐
         │   Template Generator        │
         ├─────────────────────────────┤
         │  - deployment.yaml          │
         │  - service.yaml             │
         │  - ingress.yaml             │
         │  - configmap.yaml           │
         │  - secret.yaml              │
         └─────────────────────────────┘
```

## 핵심 컴포넌트

### 1. 프로파일 시스템

프로파일은 재사용 가능한 설정 집합입니다.

#### 프로파일 계층 구조
```
base (모든 앱의 기본)
 ├── web (웹 애플리케이션)
 ├── api (API 서비스)
 ├── worker (백그라운드 워커)
 └── database (데이터베이스)
```

#### 프로파일 병합 알고리즘
```go
// 의사 코드
func mergeProfile(app AppConfig) MergedConfig {
    result := deepCopy(profiles["base"])
    
    if app.Profile != "" {
        profile := resolveProfile(app.Profile)
        result = deepMerge(result, profile)
    }
    
    result = deepMerge(result, app)
    return result
}

func resolveProfile(name string) Profile {
    profile := profiles[name]
    if profile.Extends != "" {
        parent := resolveProfile(profile.Extends)
        return deepMerge(parent, profile)
    }
    return profile
}
```

### 2. 자동 연결 엔진

서비스 간 연결을 자동으로 설정합니다.

#### 연결 유형

1. **Service Discovery**
   ```yaml
   connections: [backend]
   # → BACKEND_URL=http://release-backend:port
   ```

2. **Database Connection**
   ```yaml
   database: postgres
   # → DATABASE_URL=postgresql://postgres:5432/appname
   ```

#### URL 생성 규칙
```
서비스 URL: http://{release}-{app-name}:{port}
데이터베이스 URL: {protocol}://{database}:{port}/{app-name}
```

### 3. 스마트 변환기

축약 문법을 전체 쿠버네티스 스펙으로 변환합니다.

| 입력 | 출력 |
|------|------|
| `scale: 5` | `replicas: 5` |
| `expose: 8080` | `service: { enabled: true, port: 8080 }` |
| `host: api` | `ingress: { enabled: true, host: api.{domain} }` |

### 4. 템플릿 생성기

각 앱에 대해 필요한 쿠버네티스 리소스를 생성합니다.

#### 리소스 생성 조건

- **Deployment**: 항상 생성
- **Service**: `service.enabled = true` 또는 `expose` 설정 시
- **Ingress**: `ingress.enabled = true` 또는 `host` 설정 시
- **ConfigMap**: `config` 섹션이 있을 때
- **Secret**: `secrets` 섹션이 있을 때

## 데이터 흐름

### 1. 입력 처리
```
values.yaml → 파싱 → 검증 → 정규화
```

### 2. 프로파일 적용
```
앱 정의 → 프로파일 조회 → 상속 체인 해결 → 병합
```

### 3. 변환 및 향상
```
축약어 확장 → 연결 생성 → 기본값 적용
```

### 4. 템플릿 렌더링
```
병합된 설정 → 템플릿 엔진 → 쿠버네티스 매니페스트
```

## 헬퍼 함수

### `tmpl-apps.mergeConfig`
프로파일과 앱 설정을 병합하는 핵심 함수입니다.

```yaml
{{- $mergedConfig := include "tmpl-apps.mergeConfig" (dict "root" $ "app" $appConfig) | fromYaml }}
```

### `tmpl-apps.image`
이미지 문자열을 구성합니다.

```yaml
# 입력: "nginx" → 출력: "nginx:latest"
# 입력: { repository: "nginx", tag: "1.21" } → 출력: "nginx:1.21"
```

### `tmpl-apps.appFullname`
앱의 전체 이름을 생성합니다.

```yaml
# 패턴: {release-name}-{app-name}
# 예시: "production-frontend"
```

## 확장 포인트

### 1. 커스텀 프로파일

```yaml
profiles:
  my-custom-profile:
    extends: base
    # 커스텀 설정
```

### 2. 추가 템플릿

`templates/custom/` 디렉토리에 추가 템플릿을 배치할 수 있습니다.

### 3. 헬퍼 함수 확장

`_helpers.tpl`에 커스텀 함수를 추가할 수 있습니다.

## 성능 고려사항

### 1. 템플릿 캐싱
반복적인 include 호출을 최소화하기 위해 변수에 저장:

```yaml
{{- $mergedConfig := include "tmpl-apps.mergeConfig" ... | fromYaml }}
{{- $app := mergeOverwrite $appConfig $mergedConfig }}
```

### 2. 조건부 렌더링
불필요한 리소스 생성을 방지:

```yaml
{{- if $app.service.enabled }}
# Service 템플릿
{{- end }}
```

## 보안 고려사항

### 1. Secret 관리
- Secret은 base64로 인코딩
- 환경변수로 주입 시 `secretKeyRef` 사용

### 2. RBAC
- ServiceAccount는 필요 시에만 생성
- 최소 권한 원칙 적용

### 3. 네트워크 정책
- 향후 NetworkPolicy 지원 예정

## 한계점 및 제약사항

1. **StatefulSet 미지원**: 현재 Deployment만 지원
2. **단일 컨테이너**: 사이드카 패턴 미지원
3. **CRD 미지원**: 커스텀 리소스 정의 불가

## 향후 로드맵

1. **v0.2.0**
   - StatefulSet 지원
   - 멀티 컨테이너 지원

2. **v0.3.0**
   - NetworkPolicy 자동 생성
   - 서비스 메시 통합

3. **v1.0.0**
   - CRD 지원
   - 웹 UI 설정 도구