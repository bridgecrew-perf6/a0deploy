SHELL=/bin/bash

.PHONY: build changelog release publish-release latest latest-git-short-hash next-version

REGEX := ^v([0-9]{1,}\.){2}[0-9]{1,}$$
DEFAULT_BRANCH := $(shell git remote show origin | grep 'HEAD branch' | cut -d' ' -f5 2>/dev/null)
LATEST_VERSION := $(shell git --no-pager tag --sort=committerdate | grep -E '^v[0-9]' | sort -V | tail -1 2>/dev/null)
LATEST_GIT_TAG_SHORT_HASH := $(shell git rev-list -n 1 ${LATEST_VERSION} --abbrev-commit 2>/dev/null)
NEXT_VERSION := $(shell semtag final -s minor -o)
PWD := $(shell pwd)
ENVIRONMENT := dev

ifeq ($(LATEST_GIT_TAG_SHORT_HASH), $(shell git rev-parse --short HEAD))
  NEXT_GIT_TAG:=$(LATEST_VERSION)
else
  NEXT_GIT_TAG:=$(shell semtag final -s minor -o)
endif

build:
	docker build --pull --rm -f "Dockerfile" -t a0deploy:latest "."

run:
	docker run -it --rm a0deploy:latest

auth0-export:
	docker run -v "${PWD}/config.json:/app/config.json" -v "${PWD}/nutrien-$(ENVIRONMENT):/app/nutrien-$(ENVIRONMENT)" a0deploy:latest export --config_file /app/config.json --format directory --output_folder "/app/nutrien-$(ENVIRONMENT)"

auth0-import:
	docker run -v "${PWD}/config.json:/app/config.json" -v "${PWD}/nutrien-${ENVIRONMENT}:/app/nutrien-${ENVIRONMENT}" a0deploy:latest import --config_file /app/config.json --input_file "/app/nutrien-${ENVIRONMENT}"

changelog:
	git-chglog -o CHANGELOG.md --next-tag ${NEXT_VERSION}

release:
	@echo "Release/Tag: ${NEXT_GIT_TAG}"
	@echo $(shell git tag ${NEXT_GIT_TAG} -a -m 'Created ${NEXT_GIT_TAG}')
	@echo $(shell git branch release/${NEXT_GIT_TAG})

publish-release:
	@echo $(shell git push origin $(LATEST_VERSION))
	@echo $(shell gh release create $(LATEST_VERSION) --generate-notes)

pre-commit:
	pre-commit run --all-files

latest:
	@echo "${LATEST_VERSION}"

latest-git-short-hash:
	@echo "${LATEST_GIT_TAG_SHORT_HASH}"

next-version:
	@echo "${NEXT_VERSION}"
