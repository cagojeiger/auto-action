set -euo pipefail

HELM_CHARTS_DIR="helm-charts"

for chart in "$HELM_CHARTS_DIR"/*; do
  if [ -d "$chart" ]; then
    echo "Linting Helm chart: $chart"
    helm lint "$chart"
  fi
done
