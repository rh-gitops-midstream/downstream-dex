# Tool to build the container image. It can be either docker or podman
DOCKER ?= docker

# Override these var in release pipeline
IMAGE ?= registry.redhat.io/openshift-gitops-1/dex-rhel8:dev

# Label values for container image
CONTAINER_VERSION ?= $(shell git describe --tags --always --abbrev=7)
DOWNSTREAM_SOURCE_URL ?= $(shell git config --get remote.origin.url)
DOWNSTREAM_COMMIT_REF ?= $(shell git rev-parse HEAD)
UPSTREAM_SOURCE_URL ?= $(shell cd dex && git config --get remote.origin.url)
UPSTREAM_COMMIT_REF ?= $(shell cd dex && git rev-parse HEAD)

build-plugin:
	$(DOCKER) build -t $(IMAGE) \
		--build-arg DOWNSTREAM_SOURCE_URL="$(DOWNSTREAM_SOURCE_URL)" \
		--build-arg DOWNSTREAM_COMMIT_REF="$(DOWNSTREAM_COMMIT_REF)" \
		--build-arg UPSTREAM_SOURCE_URL="$(UPSTREAM_SOURCE_URL)" \
		--build-arg UPSTREAM_COMMIT_REF="$(UPSTREAM_COMMIT_REF)" \
		--build-arg CI_CONTAINER_VERSION="$(CI_CONTAINER_VERSION)" \
		--build-arg CI_CONTAINER_RELEASE="$(CI_CONTAINER_RELEASE)" \
		-f ./Containerfile.plugin .

# Update the dex submodule to a specific commit or tag
update-dex:
	@if [ -z "$(ref)" ]; then \
		echo "Usage: make update-dex ref=<commit-or-tag>"; \
		exit 1; \
	fi
	@if [ ! -d "./dex/.git" ]; then \
		echo "Error: 'dex' submodule is not initialized or not a valid submodule."; \
		echo "To initialize the submodule, run:"; \
		echo "    git submodule update --init --recursive"; \
		exit 1; \
	fi
	cd dex && \
	git fetch origin || { echo "Error: Failed to fetch updates for dex submodule"; exit 1; } && \
	git checkout $(ref) || { echo "Error: Failed to checkout $(ref) in dex submodule"; exit 1; } && \
	cd .. && \
	git add dex || { echo "Error: Failed to stage updated submodule"; exit 1; } && \
	echo "Successfully updated dex submodule to $(ref)"
