.PHONY: batch batch-full batch-workspace batch-no-commit batch-push batch-self-check batch-status runner-access-check prompt-wrap prompt-audit check-batch-input check-wrap-input global-train-status global-train-next global-train-once global-train-until-complete autonomous-train-status autonomous-train-next autonomous-train autonomous-train-run-current autonomous-train-until-complete repair-status repair-next repair-current
.PHONY: throughput-status throughput-next throughput-classify throughput-prep throughput-known-yellow
.PHONY: speed-status speed-next speed-once speed-train speed-train-until-blocked speed-final-gate
.PHONY: openai-build-suite-validate openai-build-suite-dry-run openai-repo-brain-index openai-evals-dry-run openai-batch-report-dry-run openai-visual-critique-dry-run openai-launch-docs-dry-run
.PHONY: visual-compile visual-validators visual-linkage visual-prose visual-vocabulary visual-surface-graph visual-dashboard visual-all visual-design-authority-all visual-no-orphan-graph surface-scenario-coverage native-iphone-interaction-grammar design-token-completeness authority-supersession faang-red-team-review visual-design-final-form-all mature-app-surface-universe-complete source-provenance-batch-linkage-complete dashboard-conflict-authority active-authority-residue-zero faang-red-team-evidence visual-design-lock-repair-05-final-gate visual-design-lock-repair-05-all
.PHONY: visual-100-priority visual-100-recipes visual-100-objects visual-100-source-debt visual-100-vocabulary visual-100-anti-generic visual-100-accessibility visual-100-proof-source-receipt visual-100-transaction visual-100-primitives visual-100-scorecards visual-100-prompt-authority visual-100-atlas visual-100-native visual-100-local-first visual-100-no-false-momentum visual-100-hidden-automation visual-100-false-green visual-100-gate visual-100-dashboard visual-100-all
.PHONY: design-system-tokens design-system-token-check design-system-contracts design-system-preview-matrix design-system-accessibility-contracts design-system-state-machines design-system-dependencies design-system-feature-services design-system-adrs design-system-proof-receipts design-system-local-trust design-system-performance design-system-authority design-system-traceability design-system-dashboard design-system-15-all

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
	@python3 scripts/ambitions-batch-prep-scaffold.py --from-queue docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json --start-at PK16 --limit 10 --output-dir docs/codex/batch-prep --dry-run

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

.PHONY: build-lab-doctor xcode-validate xcode-focused-test xcode-build-for-testing xcode-test-plan

build-lab-doctor:
	./scripts/ambitions-build-lab-doctor.sh

xcode-validate:
	./scripts/ambitions-xcode-validate.sh --batch $(BATCH) --lane $(LANE) $(ARGS)

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
	$(MAKE) visual-design-lock-repair-05-final-gate

visual-100-priority:
	python3 scripts/ambitions-visual-100-priority-registry-check.py

visual-100-recipes:
	python3 scripts/ambitions-visual-100-recipe-contract-check.py

visual-100-objects:
	python3 scripts/ambitions-visual-100-object-depth-check.py

visual-100-source-debt:
	python3 scripts/ambitions-visual-100-source-debt-check.py

visual-100-vocabulary:
	python3 scripts/ambitions-visual-100-vocabulary-full-corpus-check.py

visual-100-anti-generic:
	python3 scripts/ambitions-visual-100-anti-generic-check.py

visual-100-accessibility:
	python3 scripts/ambitions-visual-100-accessibility-adhd-check.py

visual-100-proof-source-receipt:
	python3 scripts/ambitions-visual-100-proof-source-receipt-check.py

visual-100-transaction:
	python3 scripts/ambitions-visual-100-transaction-check.py

visual-100-primitives:
	python3 scripts/ambitions-visual-100-primitive-operationality-check.py

visual-100-scorecards:
	python3 scripts/ambitions-visual-100-scorecard-check.py

visual-100-prompt-authority:
	python3 scripts/ambitions-visual-100-prompt-authority-check.py

visual-100-atlas:
	python3 scripts/ambitions-visual-100-atlas-subordination-check.py

visual-100-native:
	python3 scripts/ambitions-visual-100-native-believability-check.py

visual-100-local-first:
	python3 scripts/ambitions-visual-100-local-first-trust-check.py

visual-100-no-false-momentum:
	python3 scripts/ambitions-visual-100-no-false-momentum-check.py

visual-100-hidden-automation:
	python3 scripts/ambitions-visual-100-hidden-automation-check.py

visual-100-false-green:
	python3 scripts/ambitions-visual-100-false-green-check.py

visual-100-gate:
	python3 scripts/ambitions-visual-100-gate-check.py

visual-100-dashboard:
	python3 scripts/ambitions-visual-100-proof-dashboard.py

visual-100-all:
	python3 scripts/ambitions-surface-recipe-inventory-check.py
	python3 scripts/ambitions-surface-recipe-coverage-check.py
	python3 scripts/ambitions-surface-recipe-specificity-check.py
	python3 scripts/ambitions-train-family-frontend-extraction-check.py
	$(MAKE) visual-compile
	$(MAKE) visual-validators
	$(MAKE) visual-dashboard
	$(MAKE) visual-100-priority
	$(MAKE) visual-100-recipes
	$(MAKE) visual-100-objects
	$(MAKE) visual-100-source-debt
	$(MAKE) visual-100-vocabulary
	$(MAKE) visual-100-anti-generic
	$(MAKE) visual-100-accessibility
	$(MAKE) visual-100-proof-source-receipt
	$(MAKE) visual-100-transaction
	$(MAKE) visual-100-primitives
	$(MAKE) visual-100-scorecards
	$(MAKE) visual-100-prompt-authority
	$(MAKE) visual-100-atlas
	$(MAKE) visual-100-native
	$(MAKE) visual-100-local-first
	$(MAKE) visual-100-no-false-momentum
	$(MAKE) visual-100-hidden-automation
	$(MAKE) visual-100-false-green
	$(MAKE) visual-100-gate
	$(MAKE) visual-100-dashboard

design-system-tokens:
	python3 scripts/ambitions-token-generate.py

design-system-token-check:
	python3 scripts/ambitions-token-generate.py
	python3 scripts/ambitions-token-contract-check.py
	python3 scripts/ambitions-token-drift-check.py

design-system-contracts:
	python3 scripts/ambitions-component-contract-check.py

design-system-preview-matrix:
	python3 scripts/ambitions-preview-matrix-check.py

design-system-accessibility-contracts:
	python3 scripts/ambitions-accessibility-contract-check.py

design-system-state-machines:
	python3 scripts/ambitions-state-machine-contract-check.py

design-system-dependencies:
	python3 scripts/ambitions-dependency-boundary-check.py

design-system-feature-services:
	python3 scripts/ambitions-feature-service-boundary-check.py

design-system-adrs:
	python3 scripts/ambitions-adr-check.py

design-system-proof-receipts:
	python3 scripts/ambitions-source-proof-receipt-coverage-check.py

design-system-local-trust:
	python3 scripts/ambitions-local-first-runtime-trust-check.py

design-system-performance:
	python3 scripts/ambitions-performance-budget-check.py

design-system-authority:
	python3 scripts/ambitions-authority-ledger-check.py

design-system-traceability:
	python3 scripts/ambitions-design-to-source-trace-check.py

design-system-dashboard:
	python3 scripts/ambitions-design-system-dashboard.py

design-system-15-all:
	python3 scripts/ambitions-token-generate.py
	python3 scripts/ambitions-token-contract-check.py
	python3 scripts/ambitions-token-drift-check.py
	python3 scripts/ambitions-component-contract-check.py
	python3 scripts/ambitions-preview-matrix-check.py
	python3 scripts/ambitions-visual-regression-readiness-check.py
	python3 scripts/ambitions-accessibility-contract-check.py
	python3 scripts/ambitions-state-machine-contract-check.py
	python3 scripts/ambitions-dependency-boundary-check.py
	python3 scripts/ambitions-feature-service-boundary-check.py
	python3 scripts/ambitions-adr-check.py
	python3 scripts/ambitions-source-proof-receipt-coverage-check.py
	python3 scripts/ambitions-local-first-runtime-trust-check.py
	python3 scripts/ambitions-performance-budget-check.py
	python3 scripts/ambitions-authority-ledger-check.py
	python3 scripts/ambitions-design-to-source-trace-check.py
	python3 scripts/ambitions-design-system-dashboard.py
	grep -R "StyleDictionary\\|design-tokens\\|DesignTokens" -n DesignTokens Sources docs scripts || true
	grep -R "external.*LLM\\|cloud.*LLM" docs/canon/frontend docs/truth docs/architecture Sources Native -n || true
	grep -R "Plan" docs/canon/frontend DesignTokens docs/architecture -n || true
