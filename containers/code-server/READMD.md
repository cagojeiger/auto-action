# code-server with Kubernetes Tools

This directory contains the Dockerfile to build a `code-server` image equipped with essential Kubernetes tools: `kubectl`, `helm`, `k9s`, `skopeo`, and `mc`.

## Build

Build the Docker image for both `linux/amd64` and `linux/arm64` platforms and push it to the registry:

```bash
# Set the code-server version you want to use
export CODE_SERVER_VERSION=4.99.3

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg CODE_SERVER_VERSION=${CODE_SERVER_VERSION} \
  -t cagojeiger/code-server:${CODE_SERVER_VERSION}-k8s \
  --push \
  .
```

## Run

### Inside Kubernetes Cluster

When running this container within a Kubernetes pod, the included `gen_kube_config.sh` script (copied to `/home/coder/gen_kube_config.sh`) can be executed to automatically generate a `~/.kube/config` file using the pod's service account. This allows seamless interaction with the Kubernetes API using the installed tools (`kubectl`, `helm`, `k9s`).

Example usage within a pod definition:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: code-server-pod
spec:
  containers:
  - name: code-server
    image: cagojeiger/code-server:4.99.3-k8s # Use the built image
    command: ["/bin/bash", "-c"]
    args:
      - |
        /home/coder/gen_kube_config.sh && # Generate kubeconfig first
        /usr/bin/entrypoint.sh --bind-addr 0.0.0.0:8080 . # Start code-server
    ports:
    - containerPort: 8080
  # Ensure the pod has appropriate service account permissions
  serviceAccountName: your-service-account
```

### Locally (for debugging)

To run the container locally for debugging purposes (e.g., checking installed tools), you can use the following command:

```bash
docker run -it --rm --entrypoint bash cagojeiger/code-server:4.99.3-k8s
```

Inside the container, you can verify the installed tools:

```bash
kubectl version --client
helm version
k9s version
skopeo -v
mc --version
```

Note: Running locally won't allow interaction with a Kubernetes cluster unless you manually configure `kubectl` with appropriate credentials. The primary purpose of this image is to be run within a Kubernetes environment.