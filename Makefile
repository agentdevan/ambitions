SHELL := /bin/bash

BATCH ?= LOCAL
LANE ?= build-for-testing
TEST ?=

.PHONY: help setup build test-local xcode-build-for-testing xcode-focused-test xcode-validate swift6-final-gate native-mcp-lifecycle-check copy-scan changed-boundary clean-generated

help:
	@echo "Ambitions retained local targets"
	@echo "  make setup"
	@echo "  make build"
	@echo "  make xcode-build-for-testing BATCH=LOCAL"
	@echo "  make xcode-focused-test BATCH=LOCAL TEST=AmbitionsTests/SemanticDesignTokenCatalogTests"
	@echo "  make xcode-validate BATCH=LOCAL LANE=build-for-testing"
	@echo "  make test-local BATCH=LOCAL LANE=build-for-testing"
	@echo "  make swift6-final-gate"
	@echo "  make native-mcp-lifecycle-check"
	@echo "  make copy-scan"
	@echo "  make changed-boundary"
	@echo "  make clean-generated"

setup:
	./scripts/setup_macos_ios_dev.sh

build:
	./scripts/build-local.sh

test-local:
	./scripts/test-local.sh --batch "$(BATCH)" --lane "$(LANE)" $(if $(TEST),--test "$(TEST)")

xcode-build-for-testing:
	./scripts/ambitions-xcode-build-for-testing.sh --batch "$(BATCH)"

xcode-focused-test:
	@test -n "$(TEST)" || (echo "TEST is required. Example: make xcode-focused-test TEST=AmbitionsTests/SemanticDesignTokenCatalogTests" >&2; exit 2)
	./scripts/ambitions-xcode-test-focused.sh --batch "$(BATCH)" --test "$(TEST)"

xcode-validate:
	./scripts/ambitions-xcode-validate.sh --batch "$(BATCH)" --lane "$(LANE)" $(if $(TEST),--test "$(TEST)")

swift6-final-gate:
	./scripts/ambitions-swift6-final-gate.sh

native-mcp-lifecycle-check:
	./scripts/ambitions-native-mcp-lifecycle-check.sh

copy-scan:
	python3 scripts/ambitions-copy-contract-lint.py

changed-boundary:
	./scripts/changed-file-boundary-check.sh

clean-generated:
	rm -rf .codex output/DerivedData* output/logs tmp .generated Ambitions.xcodeproj
