.PHONY: batch batch-full batch-workspace batch-no-commit batch-push batch-self-check batch-status prompt-wrap prompt-audit check-batch-input check-wrap-input global-train-status global-train-next global-train-once global-train-until-complete autonomous-train-status autonomous-train-next autonomous-train autonomous-train-run-current autonomous-train-until-complete repair-status repair-next repair-current
.PHONY: throughput-status throughput-next throughput-classify throughput-prep throughput-known-yellow


RUNNER := scripts/ambitions-codex-train.sh
WRAPPER := scripts/ambitions-wrap-prompt.sh
AUDIT := scripts/ambitions-prompt-audit.sh
GLOBAL_SUPERVISOR := scripts/ambitions-global-train-supervisor.sh
AUTONOMOUS_TRAINER := scripts/ambitions-autonomous-train.sh
XCODE_BATCH ?= PK18
LANE ?= none
TEST ?=
TEST_PLAN ?=
RUN_ARGS ?=

check-batch-input:
	@test -n "$(BATCH)" || (echo "BATCH is required. Example: make batch BATCH=SI07 PROMPT=prompts/SI07.md" >&2; exit 2)
	@test -n "$(PROMPT)" || (echo "PROMPT is required. Example: make batch BATCH=SI07 PROMPT=prompts/SI07.md" >&2; exit 2)
	@test -x "$(RUNNER)" || (echo "$(RUNNER) is missing or not executable" >&2; exit 2)

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
