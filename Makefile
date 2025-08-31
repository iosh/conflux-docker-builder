# ##@ General

.PHONY: all
all: build

# Variables - can be overridden from the command line, e.g., `make build PUSH=true`
# Defaults are hardcoded here to remove the dependency on `yq`.
UPSTREAM_REF ?= "v3.0.1"
TESTNET_REF  ?= "v3.0.1-testnet"
ORG          ?= "iosh"
PUSH         ?= false
LOAD         ?= false
PLATFORMS    ?= "linux/amd64,linux/arm64"
TARGETS      ?= "default"
BUILDX_NAME  ?= conflux-builder

# ##@ Build Management

.PHONY: build
build: ## Build all targets defined in the 'default' group in docker-bake.yml
	@echo "==> Building images for targets [${TARGETS}] with platforms [${PLATFORMS}]..."
	@echo "==> Upstream ref: ${UPSTREAM_REF}, Testnet ref: ${TESTNET_REF}, Push: ${PUSH}, Load: ${LOAD}, Org: ${ORG}"
	UPSTREAM_REF=${UPSTREAM_REF} \
	TESTNET_REF=${TESTNET_REF} \
	ORG=${ORG} \
	IMAGE_NAME="conflux-node" \
	PUSH=${PUSH} \
	PLATFORMS=${PLATFORMS} \
	docker buildx bake \
		--file docker-bake.hcl \
		--builder ${BUILDX_NAME} \
		$(if $(filter true,${PUSH}),--push) \
		$(if $(filter true,${LOAD}),--load --set ${TARGETS}.platform=linux/amd64) \
		${TARGETS}

.PHONY: push
push: ## Build and push all targets
	$(MAKE) build PUSH=true

.PHONY: mainnet
mainnet: ## Build only the mainnet target
	$(MAKE) build TARGETS="mainnet"

.PHONY: testnet
testnet: ## Build only the testnet target
	$(MAKE) build TARGETS="testnet"

.PHONY: devnet
devnet: ## Build only the devnet target
	$(MAKE) build TARGETS="devnet"

# ##@ Buildx Environment

.PHONY: buildx-setup
buildx-setup: ## Create and bootstrap the buildx builder instance
	@if ! docker buildx ls | grep -q "${BUILDX_NAME}"; then \
		echo "==> Creating new buildx builder: ${BUILDX_NAME}"; \
		docker buildx create --name ${BUILDX_NAME} --use --bootstrap; \
	else \
		echo "==> Buildx builder '${BUILDX_NAME}' already exists."; \
	fi
	docker buildx inspect --bootstrap

.PHONY: buildx-clean
buildx-clean: ## Remove the buildx builder instance
	@echo "==> Removing buildx builder: ${BUILDX_NAME}"
	docker buildx rm ${BUILDX_NAME} || true

# ##@ Help

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help