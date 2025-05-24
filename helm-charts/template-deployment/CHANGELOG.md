# Changelog

## [0.6.0] - 2025-05-25

### Added
- **ConfigMap/Secret Management**: 템플릿별로 ConfigMap과 Secret을 생성하고 관리할 수 있는 기능 추가
  - `configMaps` 배열을 통한 다중 ConfigMap 생성 지원
  - `secrets` 배열을 통한 다중 Secret 생성 지원
  - ConfigMap/Secret을 envFrom으로 자동 참조
  - ConfigMap/Secret을 볼륨으로 자동 마운트
  - 차트 파일을 ConfigMap에 포함시키는 기능

- **Enhanced Ingress Support**: 더 유연한 Ingress 설정 지원
  - `ingress.rules` 배열을 통한 세밀한 경로 설정
  - 경로별 커스텀 백엔드 서비스 지정 가능
  - 기존 `ingress.hosts` 형식과의 하위 호환성 유지

### Documentation
- 상세한 사용자 가이드 추가 (`docs/user-guide.md`)
- 개선 제안서 작성 (`docs/improvement-proposal.md`)

### Testing
- ConfigMap/Secret 기능에 대한 포괄적인 테스트 추가
- Ingress 통합 기능에 대한 테스트 추가

## [0.5.0] - Previous releases
- 템플릿 상속 시스템
- 멀티 서비스 배포 지원
- 기본 리소스 생성 (Deployment, Service, Ingress, HPA, PDB 등)