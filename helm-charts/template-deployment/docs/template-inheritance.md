# 템플릿 상속 기능 (Template Inheritance)

템플릿 상속 기능은 템플릿 타입에 따라 기본 설정을 자동으로 적용하는 기능입니다. 이를 통해 반복적인 설정을 줄이고 일관된 구성을 유지할 수 있습니다.

## 기본 개념

1. **템플릿 타입**: 각 템플릿은 `type` 필드를 통해 하나 이상의 타입을 지정할 수 있습니다 (옵셔널).
2. **타입별 기본값**: `templateDefaults` 섹션에서 각 타입별 기본값을 정의합니다 (빈 객체도 가능).
3. **기본 템플릿**: `default` 타입은 특별한 타입으로, 모든 템플릿에 자동으로 적용됩니다.

## 우선순위

템플릿 값이 적용되는 우선순위는 다음과 같습니다:

1. **템플릿 직접 설정값**: 템플릿에 직접 설정한 값이 가장 높은 우선순위를 가집니다.
2. **타입 기본값**: 템플릿에 지정된 타입의 기본값이 적용됩니다.
   - 여러 타입이 지정된 경우, 배열에 앞에 나열된 타입이 뒤에 나열된 타입보다 우선합니다.
3. **기본 템플릿 값**: `default` 타입의 기본값이 가장 낮은 우선순위로 적용됩니다.

## 사용 방법

### 1. `values.yaml` 파일에 `templateDefaults` 섹션 정의

```yaml
templateDefaults:
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
templates:
  - name: my-web-app
    type: web
    image:
      repository: nginx
      tag: latest
```

### 3. 템플릿에 여러 타입 지정 (다중 상속)

```yaml
templates:
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
templateDefaults:
  default:
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
  web:
    service:
      port: 80
      type: ClusterIP

templates:
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
templateDefaults:
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

templates:
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

## 내부 구현

템플릿 상속은 다음 두 개의 헬퍼 함수를 통해 구현됩니다:

1. `template-deployment.getDefaults`: 템플릿 타입에 따른 기본값을 가져옵니다.
2. `template-deployment.mergeValues`: 템플릿 값과 기본값을 병합합니다.

이 함수들은 `_helpers.tpl` 파일에 정의되어 있습니다.