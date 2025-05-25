# 템플릿 상속 기능 (Template Inheritance)

템플릿 상속 기능은 템플릿 타입에 따라 기본 설정을 자동으로 적용하는 기능입니다. 이를 통해 반복적인 설정을 줄이고 일관된 구성을 유지할 수 있습니다.

## 핵심 기능

- 템플릿에 `type` 필드를 추가하여 타입별 기본값 상속 (옵셔널)
- 여러 타입을 배열로 지정하여 다중 상속 가능 (`type: [web, loadbalanced]`)
- 모든 템플릿에 적용되는 `default` 타입 지원
- `appProfiles` 섹션은 빈 객체도 가능

## 기본 개념

1. **템플릿 타입**: 각 템플릿은 `type` 필드를 통해 하나 이상의 타입을 지정할 수 있습니다 (옵셔널).
2. **타입별 기본값**: `appProfiles` 섹션에서 각 타입별 기본값을 정의합니다 (빈 객체도 가능).
3. **기본 템플릿**: `default` 타입은 특별한 타입으로, 모든 템플릿에 자동으로 적용됩니다.

## 우선순위

템플릿 값이 적용되는 우선순위는 다음과 같습니다:

1. **템플릿 직접 설정값**: 템플릿에 직접 설정한 값이 가장 높은 우선순위를 가집니다.
2. **타입 기본값**: 템플릿에 지정된 타입의 기본값이 적용됩니다.
   - 여러 타입이 지정된 경우, 배열에 앞에 나열된 타입이 뒤에 나열된 타입보다 우선합니다.
3. **기본 템플릿 값**: `default` 타입의 기본값이 가장 낮은 우선순위로 적용됩니다.

## 사용 방법

### 1. `values.yaml` 파일에 `appProfiles` 섹션 정의

```yaml
appProfiles:
  # 기본 템플릿 (모든 템플릿에 적용)
  default:
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
```

### 2. 템플릿에 `type` 필드 추가 (단일 타입)

```yaml
apps:
  - name: my-web-app
    type: web
    image:
      repository: nginx
      tag: latest
```

### 3. 템플릿에 여러 타입 지정 (다중 상속)

```yaml
apps:
  - name: my-loadbalanced-web
    type: [web, loadbalanced]
    image:
      repository: nginx
      tag: latest
```

## 예제

### 단일 타입 상속

```yaml
# values.yaml
appProfiles:
  default:
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
  web:
    service:
      port: 80
      type: ClusterIP

apps:
  - name: my-web-app
    type: web
    image:
      repository: nginx
      tag: latest
```

결과:
```yaml
# 최종 적용된 값
my-web-app:
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
  service:
    port: 80
    type: ClusterIP
  image:
    repository: nginx
    tag: latest
```

### 다중 타입 상속

```yaml
# values.yaml
appProfiles:
  default:
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
  web:
    service:
      port: 80
      type: ClusterIP
  loadbalanced:
    service:
      type: LoadBalancer
    autoscaling:
      enabled: true

apps:
  - name: my-loadbalanced-web
    type: [web, loadbalanced]
    image:
      repository: nginx
      tag: latest
```

결과:
```yaml
# 최종 적용된 값
my-loadbalanced-web:
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
  service:
    port: 80
    type: ClusterIP  # web 타입이 loadbalanced 타입보다 우선 적용됨
  autoscaling:
    enabled: true
  image:
    repository: nginx
    tag: latest
```

### 고급 예제: 마이크로서비스 아키텍처

```yaml
# values.yaml
appProfiles:
  default:
    replicaCount: 1
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
  
  # 마이크로서비스 타입의 기본값
  microservice:
    service:
      enabled: true
      type: ClusterIP
      port: 8080
    livenessProbe:
      httpGet:
        path: /actuator/health
        port: http
      initialDelaySeconds: 30
    readinessProbe:
      httpGet:
        path: /actuator/health
        port: http
      initialDelaySeconds: 5
  
  # API 타입의 기본값
  api:
    service:
      port: 3000
    livenessProbe:
      httpGet:
        path: /api/health
    readinessProbe:
      httpGet:
        path: /api/health
  
  # 고가용성 타입의 기본값
  highavailability:
    replicaCount: 3
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchExpressions:
                - key: app.kubernetes.io/name
                  operator: In
                  values:
                    - ${name}
            topologyKey: kubernetes.io/hostname
  
  # 모니터링 타입의 기본값
  monitoring:
    podAnnotations:
      prometheus.io/scrape: "true"
      prometheus.io/port: "8080"
      prometheus.io/path: "/actuator/prometheus"

apps:
  # 고가용성 API 마이크로서비스
  - name: user-service
    type: [api, microservice, highavailability, monitoring]
    image:
      repository: mycompany/user-service
      tag: v1.2.3
    env:
      - name: SPRING_PROFILES_ACTIVE
        value: "prod"
      - name: DB_HOST
        valueFrom:
          configMapKeyRef:
            name: database-config
            key: host
```

결과:
```yaml
# 최종 적용된 값
user-service:
  replicaCount: 3  # highavailability 타입에서 상속
  service:
    enabled: true  # microservice 타입에서 상속
    type: ClusterIP  # microservice 타입에서 상속
    port: 3000  # api 타입이 microservice 타입보다 우선 적용됨
  livenessProbe:
    httpGet:
      path: /api/health  # api 타입이 microservice 타입보다 우선 적용됨
      port: http  # microservice 타입에서 상속
    initialDelaySeconds: 30  # microservice 타입에서 상속
  readinessProbe:
    httpGet:
      path: /api/health  # api 타입이 microservice 타입보다 우선 적용됨
      port: http  # microservice 타입에서 상속
    initialDelaySeconds: 5  # microservice 타입에서 상속
  podAnnotations:
    prometheus.io/scrape: "true"  # monitoring 타입에서 상속
    prometheus.io/port: "8080"  # monitoring 타입에서 상속
    prometheus.io/path: "/actuator/prometheus"  # monitoring 타입에서 상속
  podAntiAffinity:  # highavailability 타입에서 상속
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
              - key: app.kubernetes.io/name
                operator: In
                values:
                  - user-service
          topologyKey: kubernetes.io/hostname
  resources:  # default 타입에서 상속
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 200m
      memory: 256Mi
  image:  # 템플릿에서 직접 설정
    repository: mycompany/user-service
    tag: v1.2.3
  env:  # 템플릿에서 직접 설정
    - name: SPRING_PROFILES_ACTIVE
      value: "prod"
    - name: DB_HOST
      valueFrom:
        configMapKeyRef:
          name: database-config
          key: host
```

## 내부 구현

템플릿 상속은 다음 두 개의 헬퍼 함수를 통해 구현됩니다:

1. `template-deployment.getDefaults`: 템플릿 타입에 따른 기본값을 가져옵니다.
2. `template-deployment.mergeValues`: 템플릿 값과 기본값을 병합합니다.

이 함수들은 `_helpers.tpl` 파일에 정의되어 있습니다.