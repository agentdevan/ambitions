.PHONY: batch batch-full batch-workspace batch-no-commit batch-status prompt-wrap prompt-audit check-batch-input check-wrap-input

RUNNER := scripts/ambitions-codex-train.sh
WRAPPER := scripts/ambitions-wrap-prompt.sh
AUDIT := scripts/ambitions-prompt-audit.sh

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
