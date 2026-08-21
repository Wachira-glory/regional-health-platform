SHELL := /bin/bash

VERIFY_BASE_URL ?=
TF_ROOT_DIR ?=
TF_CMD ?= tflocal

.PHONY: verify verify-fmt verify-terraform verify-lint verify-plan verify-gitleaks verify-trivy verify-health

verify: verify-fmt verify-terraform verify-lint verify-plan verify-gitleaks verify-trivy verify-health
	@echo
	@echo "All verification checks passed."

verify-fmt:
	@echo "==> Checking Terraform formatting"
	@terraform fmt -check -recursive

verify-terraform:
	@echo "==> Validating Terraform modules"
	@terraform -chdir=modules/data init -backend=false -input=false >/dev/null
	@terraform -chdir=modules/data validate
	@terraform -chdir=modules/service init -backend=false -input=false >/dev/null
	@terraform -chdir=modules/service validate

verify-lint:
	@echo "==> Running TFLint"
	@tflint --chdir=modules/data
	@tflint --chdir=modules/service

verify-plan:
	@if [ -z "$(TF_ROOT_DIR)" ]; then \
		echo "==> TF_ROOT_DIR not set; skipping deployed-state drift check"; \
	else \
		echo "==> Checking deployed-state drift in $(TF_ROOT_DIR)"; \
		$(TF_CMD) -chdir="$(TF_ROOT_DIR)" plan -detailed-exitcode -input=false; \
	fi

verify-gitleaks:
	@echo "==> Running Gitleaks"
	@gitleaks git . --log-opts="HEAD" --no-banner --redact

verify-trivy:
	@echo "==> Running Trivy IaC scan"
	@trivy config --severity HIGH,CRITICAL --exit-code 1 .

verify-health:
	@if [ -z "$(VERIFY_BASE_URL)" ]; then \
		echo "==> VERIFY_BASE_URL not set; skipping deployed health checks"; \
	else \
		set -e; \
		echo "==> Checking $(VERIFY_BASE_URL)/healthz"; \
		curl --fail --silent --show-error "$(VERIFY_BASE_URL)/healthz" >/dev/null; \
		echo "==> Checking $(VERIFY_BASE_URL)/readyz"; \
		curl --fail --silent --show-error "$(VERIFY_BASE_URL)/readyz" >/dev/null; \
	fi
