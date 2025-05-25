.PHONY: help lint test install template debug clean

# Default target
help:
	@echo "Tmpl Apps Helm Chart - Available targets:"
	@echo "  make lint       - Lint the helm chart"
	@echo "  make test       - Run helm unit tests"
	@echo "  make template   - Generate kubernetes manifests"
	@echo "  make debug      - Debug template generation"
	@echo "  make install    - Install chart to current cluster"
	@echo "  make clean      - Clean up generated files"

# Lint helm chart
lint:
	@echo "Linting helm chart..."
	helm lint .

# Run tests
test: lint
	@echo "Running helm unit tests..."
	@if ! helm plugin list | grep -q unittest; then \
		echo "Installing helm unittest plugin..."; \
		helm plugin install https://github.com/helm-unittest/helm-unittest.git; \
	fi
	helm unittest .

# Template generation
template:
	@echo "Generating templates..."
	helm template tmpl-apps . -f values.yaml

# Template with example values
template-example:
	@echo "Generating templates with microservices example..."
	helm template tmpl-apps . -f docs/examples/microservices.yaml

# Debug template generation
debug:
	@echo "Debug template generation..."
	helm template tmpl-apps . -f values.yaml --debug

# Install to cluster
install:
	@echo "Installing to Kubernetes cluster..."
	helm install tmpl-apps . -f values.yaml

# Dry run installation
dry-run:
	@echo "Dry run installation..."
	helm install tmpl-apps . -f values.yaml --dry-run --debug

# Package chart
package:
	@echo "Packaging helm chart..."
	helm package .

# Clean up
clean:
	@echo "Cleaning up..."
	rm -f *.tgz