# AOM-00 Validation Plan

## Scope and constraint
- Scope is audit and source map generation only; no prompt files and no product code changes are requested in this ticket.
- Outputs are confined to:
  - `artifacts/object-stage-mega-train/AOM-00-source-map.md`
  - `artifacts/object-stage-mega-train/AOM-00-risk-register.md`
  - `artifacts/object-stage-mega-train/AOM-00-validation-plan.md`
- Runner constraints are respected by keeping ephemeral validation logs under `artifacts/codex-train-v3`.

## Pre-flight evidence
1. Confirm branch / working state in execution context.
2. Read current IA and implementation authority files (`PRODUCT_DESIGN_TRUTH.md`, `IMPLEMENTATION_TRUTH.md`, `AGENTS.md`) before mapping.
3. Reconcile shell/source ownership from `AmbitionsRootView`, `AppTab`, and `AppNavigation`.

## Validation checklist
1. `git diff --check`
   - Ensure no whitespace/indexing issues in generated artifact-only patch.
2. `python3 scripts/ambitions_validate_authority_drift.py`
   - Confirm active source authority aligns with declared product truth and does not introduce forbidden IA.
3. `python3 scripts/codex/amb-master-canon-ia-validate.py`
   - Validate canonical IA contract and top-level surface invariants.
4. `python3 scripts/ambitions-local-first-boundary-scan.py`
   - Confirm local-first boundary is respected for this audit context.

## Execution notes
- All validation commands are run in repo root from `main`.
- Command outputs are recorded in terminal, and any failures are called out explicitly in final report.
- No build/test suites are part of this audit ticket unless required by validation tooling.

## Post-validation closeout
- Final report fields:
  - Status (Green/Yellow/Red)
  - Files changed
  - Artifacts generated
  - Validation run
  - Validation not run (if any)
  - Risks and residual risks
  - Rollback plan
