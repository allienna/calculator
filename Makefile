include makefiles/*.mk

.DEFAULT_GOAL := help

LANGUAGE=python
SOURCES_DIR=src
GENERATED_DIR=src

ifndef VERBOSE
MAKEFLAGS += --no-print-directory
endif

ifeq ($(UNAME),Darwin)
	SHELL := /opt/local/bin/bash
	OS_X  := true
else ifneq (,$(wildcard /etc/redhat-release))
	OS_RHEL := true
else
	OS_DEB  := true
	SHELL := /bin/bash
endif

.PHONY: help
help: ## Print this message
	 @grep -E '^[\.a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | cut -d ":" -f2- | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

