# Template Deployment Helm Chart

A flexible Helm chart for deploying multiple applications with type-based inheritance.

## Features

- **Type-based Inheritance**: Define default configurations for different application types
- **Multi-type Inheritance**: Combine multiple types for complex configurations
- **Namespace Support**: Deploy resources to different namespaces
- **Selective Resource Creation**: Enable/disable specific Kubernetes resources
- **Validation**: Schema validation for configuration values
- **Deep Merge**: Advanced merging of nested configuration objects

## Installation

```bash
helm install my-deployment ./template-deployment -f values.yaml
```

## Configuration

### Basic Example

```yaml
# values.yaml
templates:
  - name: web-app
    namespace: web
    type: web
    image:
      repository: nginx
      tag: latest
    service:
      enabled: true
      port: 80
    ingress:
      enabled: true
      hosts:
        - host: web.example.com
          paths:
            - path: /
              pathType: Prefix
```

### Type Inheritance

Define default configurations for different types:

```yaml
# values.yaml
templateDefaults:
  default:  # Applied to all templates
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
  
  web:  # Applied to templates with type: web
    service:
      enabled: true
      port: 80
  
  database:  # Applied to templates with type: database
    persistence:
      enabled: true
```

### Multi-type Inheritance

Combine multiple types (last has highest precedence):

```yaml
templates:
  - name: api-service
    type: [web, api]  # Inherits from both web and api types
    image:
      repository: my-api
      tag: v1.0.0
```

### Selective Resource Creation

Enable or disable specific resources:

```yaml
templates:
  - name: config-only
    type: web
    image:
      repository: nginx
      tag: latest
    deployment:
      enabled: false  # No Deployment will be created
    service:
      enabled: false  # No Service will be created
```

## Testing

Test the chart with the provided test values:

```bash
helm template test . -f tests/values-test.yaml
```

## Supported Resource Types

- Deployment
- Service
- Ingress
- ConfigMap
- PersistentVolumeClaim
- HorizontalPodAutoscaler
- ServiceAccount
- ClusterRole
- ClusterRoleBinding
- PodDisruptionBudget

## New in Version 0.5.1

1. **Namespace-aware Resource Naming**: Prevents resource name collisions across namespaces
2. **Improved Type Inheritance**: Added validation for type existence
3. **Enhanced Configuration Validation**: Detailed schema with validation for all properties
4. **Selective Resource Creation**: Fine-grained control over which resources to create
5. **Test Values**: Added test values files for verification