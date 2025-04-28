#!/usr/bin/env bash
set -euxo pipefail

mkdir -p ~/.kube
cat <<EOF > ~/.kube/config
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    server: https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: default
  name: default
current-context: default
users:
- name: default
  user:
    token: $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
EOF
