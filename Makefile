# Local build and test only — CI is the sole publisher.
# Shared pipelines: https://github.com/nforceroh/.github
SHELL := /bin/bash
IMAGE ?= ghcr.io/nforceroh/nginx-php
TAG   ?= dev

.PHONY: build test run

build:
	docker build \
		--build-arg BUILD_DATE="$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')" \
		--build-arg VERSION="$(TAG)" \
		--tag $(IMAGE):$(TAG) .

test: build
	./tests/run_tests.sh "$(IMAGE):$(TAG)"

# Base image for downstream web apps (snappymail, vimbadmin): serves
# /data/web over 8080. Mount your app at /data/web and config at /config.
run: build
	docker run --rm -it \
		-p 8080:8080 \
		-v "$$PWD/../../nginx-php-config:/config" \
		$(IMAGE):$(TAG)
