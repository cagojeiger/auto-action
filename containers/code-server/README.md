# code-server with Kubernetes Tools

This Docker image bundles `code-server` with essential Kubernetes tools: `kubectl`, `helm`, `k9s`, `skopeo`, and `mc`.

## Build

Build and push the multi-platform image:

```bash
# Set the desired code-server version
export CODE_SERVER_VERSION=4.99.3

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg CODE_SERVER_VERSION=${CODE_SERVER_VERSION} \
  -t cagojeiger/code-server:${CODE_SERVER_VERSION}-k8s \
  --push \
  .
```

## Run

### Inside Kubernetes

The container includes `/home/coder/gen_kube_config.sh` to automatically configure `kubectl` using the pod's service account upon startup.

Example command within a pod spec:
```yaml
    command: ["/bin/bash", "-c"]
    args:
      - |
        /home/coder/gen_kube_config.sh && # Generate kubeconfig
        /usr/bin/entrypoint.sh --bind-addr 0.0.0.0:8080 . # Start code-server
```

### Locally (for debugging)

To inspect the tools inside the container:

```bash
docker run -it --rm --entrypoint bash cagojeiger/code-server:4.99.3-k8s
```