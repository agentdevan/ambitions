# PLOS Goal

Status: Active Goal Mode program authority for PLOS
Program: Personal Life OS Runtime Master Build
Current allowed run type: autonomous readiness hardening only
Current execution state: PLOS-M00 not executed; owner review required before first runtime-program execution

## Mission

Upgrade the PLOS control plane so the full Linear PLOS project can run through Goal Mode without synthetic issue drift, false Green, context churn, privacy/source/safety drift, or phase-order violations.

This file does not prove runtime implementation. It defines the governance, queue, validation, reviewer, and closeout rules that must be Green before PLOS execution starts.

## Non-Goals

- Do not implement PLOS runtime features from this readiness packet.
- Do not execute `PLOS-M00` / `AMB-608` from this readiness packet.
- Do not create branches or PRs for normal PLOS execution unless a future active issue changes branch policy.
- Do not introduce required cloud LLM, hosted planning, analytics, telemetry, or custom backend dependencies.
- Do not place private user data in R2, public Source Atlas objects, or external source packs.
- Do not claim release, TestFlight, device, accessibility, privacy, App Review, or performance readiness without matching proof.

## Authority

Read these before any PLOS source-changing run:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. `artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.md`
10. `artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.md`
11. `artifacts/plos-runtime/PLOS-run-state.md`
12. `artifacts/plos-runtime/PLOS_PHASE_GATES.md`
13. `.agents/skills/plos-runtime-master-build/SKILL.md`
14. Relevant live source, tests, scripts, Linear issue, and proof artifacts for the active `AMB-*` issue

Truth files outrank this file. Linear issue content outranks stale local planning only after the issue has been resolved to the actual `AMB-*` identifier.

## Linear Binding Law

PLOS labels are aliases. Linear identifiers are `AMB-*`.

- `PLOS-M00` resolves to `AMB-608`.
- `PLOS-M01` resolves to `AMB-609`.
- Continue through `PLOS-M26` as declared in `PLOS_LINEAR_ISSUE_MAP.json`.
- Never fetch, comment, update, or close out Linear work using `PLOS-M##` or `PLOS-###`.
- If a child issue label is needed, resolve it to the live `AMB-*` child issue before work starts and record that binding in the active packet/run-state.
- Any unresolved PLOS label is Red for execution.

## Program Artifacts

Required readiness artifacts:

- `artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.md`
- `artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.json`
- `artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.md`
- `artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json`
- `artifacts/plos-runtime/PLOS_PHASE_GATES.md`
- `artifacts/plos-runtime/PLOS_RISK_REGISTER.md`
- `artifacts/plos-runtime/PLOS_AUTONOMOUS_READINESS_AUDIT.md`
- `.agents/skills/plos-runtime-master-build/SKILL.md`
- `.agents/skills/plos-runtime-master-build/references/plos-reviewer-prompts.md`
- `.agents/skills/plos-runtime-master-build/references/plos-closeout-template.md`
- `scripts/codex/plos-readiness-validate.py`
- `scripts/codex/program-preflight.sh`
- `scripts/codex/program-phase-gate.sh`
- `scripts/codex/linear-closeout-validate.py`

Supporting Source Atlas readiness artifacts:

- `artifacts/source-atlas-factory/SAF_HARDENING_PLAN.md`
- `scripts/codex/source-atlas-readiness-validate.py`
- `.agents/skills/source-atlas-factory/SKILL.md`

## Execution Sequence

1. Confirm branch is `main` and capture `BASE_SHA`.
2. Read active truth files and this PLOS goal packet.
3. Resolve the active phase label to its `AMB-*` Linear issue.
4. Resolve any child issue label to its `AMB-*` Linear issue before Linear access.
5. Run `scripts/codex/program-preflight.sh plos`.
6. Run `scripts/codex/program-phase-gate.sh plos <phase>`.
7. Inspect live source ownership before any source edit.
8. Keep the patch scoped to the active `AMB-*` issue.
9. Run focused validation and any required reviewer prompts.
10. Validate closeout text with `python3 scripts/codex/linear-closeout-validate.py --program plos`.
11. Commit and push only validated scoped work.
12. Update Linear with evidence-backed status using the `AMB-*` issue identifier.

## Phase Order

PLOS phases run strictly `M00` through `M26`, using the queue in `PLOS_EXECUTION_QUEUE.json`.

Broad runtime expansion is blocked until:

- M00 governance/law is Green or accepted Yellow.
- M01 live runtime truth map is Green or accepted Yellow.
- M02 through M09 foundations and safety gates are satisfied.
- M10 Golden Slice gate proves the vertical slice boundary before scaling.

## Green / Yellow / Red

Green means the scoped phase or readiness task is complete, AMB-bound, validated, and no proof claim exceeds evidence.

Yellow means the scoped work is structurally correct but a named validation, external proof, owner review, device check, or child-map refresh remains incomplete and owned.

Red means execution must stop. Red includes:

- PLOS label used as a Linear identifier.
- Synthetic issue drift.
- PLOS-M00 execution before owner review for this readiness packet.
- Runtime feature implementation during readiness hardening.
- Private user data in R2 or public Source Atlas material.
- Required cloud LLM/core server dependency.
- Missing receipt, source binding, rollback, or safety gate for source packs.
- Phase order violation.
- Release, accessibility, privacy, device, performance, or App Review claims without proof.

## Closeout Boundary

Every PLOS closeout must state:

- The actual `AMB-*` issue(s) covered.
- Whether PLOS-M00 or any runtime phase was executed.
- Whether app source changed.
- Whether runtime features were implemented.
- Validations run and failures.
- Linear update target and identifier.
- Yellow/Red limits and next eligible action.

For this readiness hardening packet, correct closeout says: docs/scripts/skills/artifacts only; no runtime features; PLOS-M00 not executed; stop for owner review.
