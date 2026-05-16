# Ambitions root make extension.
# GNU make reads GNUmakefile before Makefile; keep the existing Makefile as the primary body.
include Makefile

.PHONY: ui-decision-new ui-decision-check ui-decision-link-check ui-decision-sync ui-decision-prompt ui-decision-final-gate ui-decision-all

ui-decision-new:
	@python3 scripts/ambitions-ui-decision-new.py $(ARGS)

ui-decision-check:
	@python3 scripts/ambitions-ui-decision-check.py

ui-decision-link-check:
	@python3 scripts/ambitions-ui-decision-recipe-link-check.py

ui-decision-sync:
	@python3 scripts/ambitions-ui-decision-sync.py $(if $(DECISION),--decision $(DECISION)) $(if $(INCLUDE_DRAFT),--include-draft)

ui-decision-prompt:
	@test -n "$(DECISION)" || (echo "DECISION is required. Example: make ui-decision-prompt DECISION=UID-2026-05-15-today-local-ambitions-lockup" >&2; exit 2)
	@python3 scripts/ambitions-ui-decision-implementation-prompt.py --decision $(DECISION) $(if $(BATCH),--batch $(BATCH))

ui-decision-final-gate:
	@python3 scripts/ambitions-ui-decision-final-gate.py

ui-decision-all:
	@python3 scripts/ambitions-ui-decision-check.py
	@python3 scripts/ambitions-ui-decision-recipe-link-check.py
	@python3 scripts/ambitions-ui-decision-sync.py
	@python3 scripts/ambitions-ui-decision-final-gate.py
