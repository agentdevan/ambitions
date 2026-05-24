.PHONY: batch batch-full batch-workspace batch-no-commit batch-push batch-read-only-audit batch-self-check batch-status runner-access-check prompt-wrap prompt-audit check-batch-input check-wrap-input global-train-status global-train-next global-train-once global-train-until-complete autonomous-train-status autonomous-train-next autonomous-train autonomous-train-run-current autonomous-train-until-complete repair-status repair-next repair-current
.PHONY: source-atlas-coverage-inventory source-atlas-coverage-dry-run source-atlas-generate-scenarios source-atlas-mutate-scenarios source-atlas-validate-scenarios source-atlas-generate-candidates source-atlas-score-candidates source-atlas-dedupe-candidates source-atlas-promote-fixtures source-atlas-coverage-report source-atlas-coverage-proof
.PHONY: repo-doctor repo-doctor-strict canon-install codex-os-context codex-os-next codex-os-sync codex-os-performance codex-os-repair-route codex-os-batch-select authorized-batch autonomy-loop
.PHONY: throughput-status throughput-next throughput-classify throughput-prep throughput-known-yellow
.PHONY: speed-status speed-next speed-once speed-train speed-train-until-blocked speed-final-gate xcode-benchmark
.PHONY: openai-build-suite-validate openai-build-suite-dry-run openai-repo-brain-index openai-evals-dry-run openai-batch-report-dry-run openai-visual-critique-dry-run openai-launch-docs-dry-run
.PHONY: visual-compile visual-validators visual-linkage visual-prose visual-vocabulary visual-surface-graph visual-dashboard visual-all visual-design-authority-all visual-no-orphan-graph surface-scenario-coverage native-iphone-interaction-grammar design-token-completeness authority-supersession faang-red-team-review visual-design-final-form-all mature-app-surface-universe-complete source-provenance-batch-linkage-complete dashboard-conflict-authority active-authority-residue-zero faang-red-team-evidence visual-design-lock-repair-05-final-gate visual-design-lock-repair-05-all validate-visual-proof
.PHONY: frontend-authority-packet frontend-authority-packets-p0 frontend-authority-packets-all frontend-authority-preflight frontend-implementation-prompt frontend-source-bindings frontend-drift-check frontend-implementation-dashboard frontend-next-surface-queue frontend-receipt-check frontend-proof-contract-check encyclopedia-to-frontend-os-final-gate encyclopedia-to-frontend-os-all
.PHONY: visual-100-priority visual-100-recipes visual-100-objects visual-100-source-debt visual-100-vocabulary visual-100-anti-generic visual-100-accessibility visual-100-proof-source-receipt visual-100-transaction visual-100-primitives visual-100-scorecards visual-100-prompt-authority visual-100-atlas visual-100-native visual-100-local-first visual-100-no-false-momentum visual-100-hidden-automation visual-100-false-green visual-100-gate visual-100-dashboard visual-100-all
.PHONY: design-system-tokens design-system-token-check design-system-contracts design-system-preview-matrix design-system-accessibility-contracts design-system-state-machines design-system-dependencies design-system-feature-services design-system-adrs design-system-proof-receipts design-system-local-trust design-system-performance design-system-authority design-system-traceability design-system-dashboard design-system-15-all
.PHONY: xcodebuildmcp-register scripts-inventory scripts-doctor

RUNNER := scripts/ambitions-codex-train.sh
WRAPPER := scripts/ambitions-wrap-prompt.sh
AUDIT := scripts/ambitions-prompt-audit.sh
GLOBAL_SUPERVISOR := scripts/ambitions-global-train-supervisor.sh
AUTONOMOUS_TRAINER := scripts/ambitions-autonomous-train.sh
SPEED_TRAINER := scripts/ambitions-speed-train.sh
XCODE_BATCH ?= PK18
LANE ?= none
TEST ?=
TEST_PLAN ?=
RUN_ARGS ?=
RECIPE ?= core_runtime_minimum
MAX ?= 300
SEED ?= 17
OUTPUT ?=
INPUT ?=
CANDIDATES ?= source-atlas/generated/candidates/candidates.json
SCENARIOS ?= source-atlas/generated/accepted/accepted-scenarios.json

check-batch-input:
	@test -n "$(BATCH)" || (echo "BATCH is required. Example: make batch BATCH=SI07 PROMPT=prompts/SI07.md" >&2; exit 2)
	@test -n "$(PROMPT)" || (echo "PROMPT is required. Example: make batch BATCH=SI07 PROMPT=prompts/SI07.md" >&2; exit 2)
	@test -x "$(RUNNER)" || (echo "$(RUNNER) is missing or not executable" >&2; exit 2)
	@python3 scripts/ambitions-runner-access-guard.py

batch: batch-full

batch-full: check-batch-input
	ACCESS_MODE=full AUTO_COMMIT=1 "$(RUNNER)" "$(BATCH)" "$(PROMPT)"

batch-workspace: check-batch-input
	ACCESS_MODE=workspace AUTO_COMMIT=1 "$(RUNNER)" "$(BATCH)" "$(PROMPT)"

batch-no-commit: check-batch-input
	ACCESS_MODE=full AUTO_COMMIT=0 "$(RUNNER)" "$(BATCH)" "$(PROMPT)"

batch-push: check-batch-input
	AUTO_PUSH=1 ACCESS_MODE=full AUTO_COMMIT=1 "$(RUNNER)" "$(BATCH)" "$(PROMPT)"

batch-read-only-audit: check-batch-input
	READ_ONLY_AUDIT=1 AUTO_BRANCH=0 AUTO_COMMIT=0 AUTO_PUSH=0 "$(RUNNER)" "$(BATCH)" "$(PROMPT)"

batch-self-check:
	"$(RUNNER)" --self-check

runner-access-check:
	@python3 scripts/ambitions-runner-access-guard.py

batch-status:
	@echo "Recent Codex batch runs:"
	@find .codex/runs -mindepth 2 -maxdepth 2 -type d 2>/dev/null | sort | tail -20 || true
	@echo
	@git status --short --branch

check-wrap-input:
	@test -n "$(BATCH)" || (echo "BATCH is required. Example: make prompt-wrap BATCH=SI07 INPUT=/tmp/raw.md" >&2; exit 2)
	@test -n "$(INPUT)" || (echo "INPUT is required. Example: make prompt-wrap BATCH=SI07 INPUT=/tmp/raw.md" >&2; exit 2)
	@test -x "$(WRAPPER)" || (echo "$(WRAPPER) is missing or not executable" >&2; exit 2)

prompt-wrap: check-wrap-input
	"$(WRAPPER)" "$(BATCH)" "$(INPUT)" $(if $(OUTPUT),"$(OUTPUT)")

prompt-audit:
	@test -x "$(AUDIT)" || (echo "$(AUDIT) is missing or not executable" >&2; exit 2)
	"$(AUDIT)"

global-train-status:
	@test -x "$(GLOBAL_SUPERVISOR)" || (echo "$(GLOBAL_SUPERVISOR) is missing or not executable" >&2; exit 2)
	"$(GLOBAL_SUPERVISOR)" --status

global-train-next:
	@test -x "$(GLOBAL_SUPERVISOR)" || (echo "$(GLOBAL_SUPERVISOR) is missing or not executable" >&2; exit 2)
	"$(GLOBAL_SUPERVISOR)" --next

global-train-once:
	@test -x "$(GLOBAL_SUPERVISOR)" || (echo "$(GLOBAL_SUPERVISOR) is missing or not executable" >&2; exit 2)
	"$(GLOBAL_SUPERVISOR)" --once

global-train-until-complete:
	@test -x "$(GLOBAL_SUPERVISOR)" || (echo "$(GLOBAL_SUPERVISOR) is missing or not executable" >&2; exit 2)
	"$(GLOBAL_SUPERVISOR)" --until-complete

autonomous-train-status:
	@test -x "$(AUTONOMOUS_TRAINER)" || (echo "$(AUTONOMOUS_TRAINER) is missing or not executable" >&2; exit 2)
	"$(AUTONOMOUS_TRAINER)" --status

autonomous-train-next:
	@test -x "$(AUTONOMOUS_TRAINER)" || (echo "$(AUTONOMOUS_TRAINER) is missing or not executable" >&2; exit 2)
	"$(AUTONOMOUS_TRAINER)" --next

autonomous-train:
	@test -x "$(AUTONOMOUS_TRAINER)" || (echo "$(AUTONOMOUS_TRAINER) is missing or not executable" >&2; exit 2)
	"$(AUTONOMOUS_TRAINER)" --until-complete

autonomous-train-run-current:
	@test -x "$(AUTONOMOUS_TRAINER)" || (echo "$(AUTONOMOUS_TRAINER) is missing or not executable" >&2; exit 2)
	"$(AUTONOMOUS_TRAINER)" --run-current

autonomous-train-until-complete:
	@test -x "$(AUTONOMOUS_TRAINER)" || (echo "$(AUTONOMOUS_TRAINER) is missing or not executable" >&2; exit 2)
	"$(AUTONOMOUS_TRAINER)" --until-complete

repair-status:
	@scripts/ambitions-process-preflight.sh --status
	@git status --short --branch

repair-next:
	@batch="$( \
	  awk '/^## Current Active Attempt/{in_active=1; finalization=0; next} \
	  in_active && NR > 1 && /^## / {exit 0} \
	  in_active && /^status:[[:space:]]*finalization-required[[:space:]]*$$/ {finalization=1; next} \
	  in_active && /^status:/ && $0 !~ /^status:[[:space:]]*finalization-required[[:space:]]*$$/ {finalization=0} \
	  in_active && /selected child batch:/ {sub(/^.*selected child batch:[[:space:]]*/, \"\", $0); gsub(/^[[:space:]]+|[[:space:]]+$$/, \"\", $0); if (finalization && $0 != \"\") {print $0 \"-FINALIZE-01\"; exit}} \
	  ' .codex/state/global-train-attempt-ledger.md \
	  | awk '{print $$1; exit}' )"; \
	if [ -n "$$batch" ]; then \
	  echo "$$batch"; \
	  exit 0; \
	fi; \
	for file in prompts/batches/*-FINALIZE-01.md; do \
	  if [ -f "$$file" ]; then \
	    base="$${file##*/}"; \
	    echo "$${base%.md}"; \
	    exit 0; \
	  fi; \
	done; \
	for file in prompts/batches/*-REPAIR-01.md; do \
	  if [ -f "$$file" ]; then \
	    base="$${file##*/}"; \
	    echo "$${base%.md}"; \
	    exit 0; \
	  fi; \
	done; \
	scripts/ambitions-global-train-supervisor.sh --next | awk '/^Next batch:/{print $$3; exit}'

repair-current:
	@target=`make -s repair-next`; \
	if [ -z "$$target" ]; then \
	  echo "no repair/finalization target found" >&2; \
	  exit 1; \
	fi; \
	case "$$target" in \
	  *-FINALIZE-01|*-REPAIR-01) : ;; \
	  *) \
	    echo "refusing to run non-fix target: $$target" >&2; \
	    exit 1; \
	    ;; \
	esac; \
	prompt="prompts/batches/$$target.md"; \
	if [ ! -f "$$prompt" ]; then \
	  echo "prompt missing: $$prompt" >&2; \
	  exit 2; \
	fi; \
	scripts/ambitions-process-preflight.sh --assert-clear; preflight_exit=$$?; \
	if [ $$preflight_exit -ne 0 ]; then \
	  echo "repair autopilot preflight blocked; classify and clean blockers before running the target" >&2; \
	  exit $$preflight_exit; \
	fi; \
	printf 'Running repair/finalization command:\\n'; \
	printf 'ALLOW_DIRTY=1 ALLOW_MAIN_COMMIT=1 AUTO_BRANCH=0 make batch BATCH=%s PROMPT=%s\\n' "$$target" "$$prompt"; \
	ALLOW_DIRTY=1 ALLOW_MAIN_COMMIT=1 AUTO_BRANCH=0 make batch BATCH="$$target" PROMPT="$$prompt"

repo-doctor:
	python3 scripts/governance/ambitions-repo-doctor.py

repo-doctor-strict:
	python3 scripts/governance/ambitions-repo-doctor.py --strict

source-atlas-coverage-inventory:
	@sed -n '1,240p' docs/audits/source-atlas-coverage-universe-inventory.md

source-atlas-coverage-dry-run:
	python3 tools/source-atlas/coverage.py expand --recipe "$(RECIPE)" --max "$(MAX)" --seed "$(SEED)" --dry-run

source-atlas-generate-scenarios:
	python3 tools/source-atlas/coverage.py expand --recipe "$(RECIPE)" --max "$(MAX)" --seed "$(SEED)" $(if $(OUTPUT),--output "$(OUTPUT)")

source-atlas-mutate-scenarios:
	@test -n "$(INPUT)" || (echo "INPUT is required. Example: make source-atlas-mutate-scenarios INPUT=source-atlas/generated/proof/scenarios-seed-a.json" >&2; exit 2)
	python3 tools/source-atlas/coverage.py mutate --input "$(INPUT)" --max "$(MAX)" --seed "$(SEED)" $(if $(OUTPUT),--output "$(OUTPUT)")

source-atlas-validate-scenarios:
	@test -n "$(INPUT)" || (echo "INPUT is required. Example: make source-atlas-validate-scenarios INPUT=source-atlas/generated/proof/scenarios-with-mutations.json" >&2; exit 2)
	python3 tools/source-atlas/coverage.py validate --input "$(INPUT)"

source-atlas-generate-candidates:
	@test -n "$(INPUT)" || (echo "INPUT is required. Example: make source-atlas-generate-candidates INPUT=source-atlas/generated/accepted/accepted-scenarios.json" >&2; exit 2)
	python3 tools/source-atlas/coverage.py candidates --input "$(INPUT)" --max "$(MAX)" $(if $(OUTPUT),--output "$(OUTPUT)")

source-atlas-score-candidates:
	python3 tools/source-atlas/coverage.py score --input "$(CANDIDATES)" --scenarios "$(SCENARIOS)"

source-atlas-dedupe-candidates:
	python3 tools/source-atlas/coverage.py dedupe --input "$(CANDIDATES)"

source-atlas-promote-fixtures:
	python3 tools/source-atlas/coverage.py promote --input "$(CANDIDATES)" --scenarios "$(SCENARIOS)" --max "$(MAX)"

source-atlas-coverage-report:
	python3 tools/source-atlas/coverage.py report --scenarios "$(SCENARIOS)" --candidates "$(CANDIDATES)"

source-atlas-coverage-proof:
	python3 tools/source-atlas/coverage.py proof --seed "$(SEED)"

canon-install:
	python3 scripts/governance/ambitions-canon-installer.py

codex-os-context:
	python3 scripts/codex-os/ambitions-codex-os-context-pack.py

codex-os-next:
	python3 scripts/codex-os/ambitions-codex-os-next-action.py

codex-os-sync:
	python3 scripts/codex-os/ambitions-codex-os-sync-governance.py

codex-os-performance:
	python3 scripts/codex-os/ambitions-codex-os-performance-check.py

codex-os-repair-route:
	python3 scripts/codex-os/ambitions-codex-os-repair-router.py

codex-os-batch-select:
	python3 scripts/codex-os/ambitions-codex-os-batch-selector.py

authorized-batch:
	@test -n "$(BATCH)" || (echo "BATCH is required. Example: make authorized-batch BATCH=FCP27 PROMPT=prompts/batches/FCP27.md" >&2; exit 2)
	@test -n "$(PROMPT)" || (echo "PROMPT is required. Example: make authorized-batch BATCH=FCP27 PROMPT=prompts/batches/FCP27.md" >&2; exit 2)
	@bash scripts/ambitions-authorized-batch.sh "$(BATCH)" "$(PROMPT)"

autonomy-loop:
	@python3 scripts/governance/ambitions-canon-installer.py && \
	python3 scripts/governance/ambitions-repo-doctor.py && \
	python3 scripts/codex-os/ambitions-codex-os-sync-governance.py && \
	python3 scripts/codex-os/ambitions-codex-os-next-action.py

throughput-status:
	@echo "Throughput status snapshot"
	@git status --short --branch
	@make batch-self-check
	@make prompt-audit
	@make autonomous-train-status
	@make autonomous-train-next

throughput-next:
	@echo "Throughput next-lane command"
	@bash scripts/ambitions-throughput-plan.sh --next

throughput-classify:
	@echo "Throughput lane classification sample"
	@bash scripts/ambitions-throughput-plan.sh --classify --limit 20

throughput-prep:
	@echo "Throughput prep scaffold dry run"
	@echo "Non-IOS26 queue prep is historical under docs/codex/GLOBAL_BATCH_SEQUENCE.md"
	@python3 scripts/ambitions-next-batch-resolver.py

throughput-known-yellow:
	@echo "Throughput known-yellow scan"
	@bash scripts/ambitions-known-yellow-scan.sh

speed-status:
	@bash "$(SPEED_TRAINER)" --status

speed-next:
	@bash "$(SPEED_TRAINER)" --next

speed-once:
	@bash "$(SPEED_TRAINER)" --once

speed-train:
	@bash "$(SPEED_TRAINER)" --until-blocked

speed-train-until-blocked:
	@bash "$(SPEED_TRAINER)" --until-blocked

speed-final-gate:
	@bash "$(SPEED_TRAINER)" --final-gate

build-lab-doctor:
	./scripts/ambitions-build-lab-doctor.sh

xcodebuildmcp-register:
	bash scripts/ambitions-xcodebuildmcp-register.sh

xcode-validate:
	./scripts/ambitions-xcode-validate.sh --batch $(BATCH) --lane $(LANE) $(ARGS)

xcode-benchmark:
	./scripts/ambitions-xcode-benchmark.sh --batch $(BATCH) --lane $(LANE) -- $(CMD)

xcode-focused-test:
	./scripts/ambitions-xcode-validate.sh --batch $(BATCH) --lane focused-test --test $(TEST)

xcode-build-for-testing:
	./scripts/ambitions-xcode-validate.sh --batch $(BATCH) --lane build-for-testing

xcode-test-plan:
	./scripts/ambitions-xcode-validate.sh --batch $(BATCH) --lane test-plan --test-plan $(TEST_PLAN)

ambitions-codex-os-validate:
	python3 scripts/ambitions-codex-os-validate.py

ambitions-codex-os-doctor:
	python3 scripts/ambitions-codex-os-doctor.py

scripts-inventory:
	@python3 scripts/ambitions-script-doctor.py --summary-only

scripts-doctor:
	python3 scripts/ambitions-script-doctor.py

openai-build-suite-validate:
	python3 scripts/openai-build-suite-validate.py

openai-build-suite-dry-run:
	python3 scripts/openai-build-suite-dry-run.py

openai-repo-brain-index:
	python3 tools/openai/repo_brain/build_repo_manifest.py

openai-evals-dry-run:
	python3 tools/openai/evals/run_evals.py --dry-run

openai-batch-report-dry-run:
	python3 tools/openai/batch_report/classify_batch_result.py --help >/dev/null

openai-visual-critique-dry-run:
	python3 tools/openai/visual_critique/critique_visual_packet.py --rubric tools/openai/visual_critique/rubrics/ambitions_visual_canon.json --dry-run

openai-launch-docs-dry-run:
	python3 tools/openai/launch_docs/generate_launch_packet.py --dry-run

visual-compile:
	python3 -m py_compile \
		scripts/ambitions-surface-recipe-inventory-check.py \
		scripts/ambitions-surface-recipe-coverage-check.py \
		scripts/ambitions-surface-recipe-specificity-check.py \
		scripts/ambitions-train-family-frontend-extraction-check.py \
		scripts/ambitions-visual-source-linkage-check.py \
		scripts/ambitions-visual-template-residue-check.py \
		scripts/ambitions-visual-vocabulary-boundary-check.py \
		scripts/ambitions-visual-surface-graph-check.py \
		scripts/ambitions-visual-dashboard.py

visual-linkage:
	python3 scripts/ambitions-visual-source-linkage-check.py

visual-prose:
	python3 scripts/ambitions-visual-template-residue-check.py

visual-vocabulary:
	python3 scripts/ambitions-visual-vocabulary-boundary-check.py

visual-surface-graph:
	python3 scripts/ambitions-visual-surface-graph-check.py

visual-dashboard:
	python3 scripts/ambitions-visual-dashboard.py

visual-validators: visual-linkage visual-prose visual-vocabulary visual-surface-graph

visual-all: visual-compile visual-validators visual-dashboard

visual-design-authority-all: visual-100-all design-system-15-all

visual-no-orphan-graph:
	python3 scripts/ambitions-visual-no-orphan-graph-check.py

validate-visual-proof:
	python3 scripts/ambitions_validate_visual_proof.py

surface-scenario-coverage:
	python3 scripts/ambitions-surface-scenario-coverage-check.py

native-iphone-interaction-grammar:
	python3 scripts/ambitions-native-iphone-interaction-grammar-check.py

design-token-completeness:
	python3 scripts/ambitions-design-token-completeness-check.py

authority-supersession:
	python3 scripts/ambitions-authority-supersession-check.py

faang-red-team-review:
	python3 scripts/ambitions-faang-red-team-review-check.py

mature-app-surface-universe-complete:
	python3 scripts/ambitions-mature-app-surface-universe-complete-check.py

source-provenance-batch-linkage-complete:
	python3 scripts/ambitions-source-provenance-batch-linkage-complete-check.py

dashboard-conflict-authority:
	python3 scripts/ambitions-dashboard-conflict-authority-check.py

active-authority-residue-zero:
	python3 scripts/ambitions-active-authority-residue-zero-check.py

faang-red-team-evidence:
	python3 scripts/ambitions-faang-red-team-evidence-check.py

visual-design-lock-repair-05-final-gate:
	python3 scripts/ambitions-visual-design-lock-repair-05-final-gate.py

visual-design-final-form-all:
	$(MAKE) visual-design-authority-all
	$(MAKE) visual-no-orphan-graph
	$(MAKE) surface-scenario-coverage
	$(MAKE) native-iphone-interaction-grammar
	$(MAKE) design-token-completeness
	$(MAKE) authority-supersession
	$(MAKE) faang-red-team-review

visual-design-lock-repair-05-all:
	$(MAKE) visual-all
	$(MAKE) visual-100-all
	$(MAKE) design-system-15-all
	$(MAKE) visual-design-final-form-all
	$(MAKE) mature-app-surface-universe-complete
	$(MAKE) source-provenance-batch-linkage-complete
	$(MAKE) dashboard-conflict-authority
	$(MAKE) active-authority-residue-zero
	$(MAKE) faang-red-team-evidence

frontend-authority-packet:
	python3 scripts/ambitions-frontend-authority-packet.py --surface $(SURFACE)

frontend-authority-packets-p0:
	python3 scripts/ambitions-frontend-authority-packets-p0.py

frontend-authority-packets-all:
	python3 scripts/ambitions-frontend-authority-packets-all.py

frontend-authority-preflight:
	python3 scripts/ambitions-frontend-authority-preflight.py --surface $(SURFACE)

frontend-implementation-prompt:
	python3 scripts/ambitions-frontend-implementation-prompt.py --surface $(SURFACE)

frontend-source-bindings:
	python3 scripts/ambitions-frontend-source-bindings.py

frontend-drift-check:
	python3 scripts/ambitions-frontend-drift-check.py

frontend-implementation-dashboard:
	python3 scripts/ambitions-frontend-implementation-dashboard.py

frontend-next-surface-queue:
	python3 scripts/ambitions-frontend-next-surface-queue.py

frontend-receipt-check:
	python3 scripts/ambitions-frontend-receipt-check.py

frontend-proof-contract-check:
	python3 scripts/ambitions-frontend-proof-contract-check.py

encyclopedia-to-frontend-os-final-gate:
	python3 scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py

encyclopedia-to-frontend-os-all: frontend-authority-packets-all frontend-source-bindings frontend-drift-check frontend-implementation-dashboard frontend-receipt-check frontend-proof-contract-check encyclopedia-to-frontend-os-final-gate
