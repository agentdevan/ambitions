---
name: plos-runtime-master-build
description: Phase-gated Goal Mode control plane for Ambitions Personal Life OS Runtime Master Build work, including PLOS Linear issue binding, phase gates, reviewer prompts, closeout validation, and no-false-Green execution.
---

# PLOS Runtime Master Build

Use this skill for PLOS runtime-program governance, readiness hardening, phase execution, reviewer passes, and closeout. It is subordinate to `docs/truth/*`, `AGENTS.md`, active Linear `AMB-*` issues, and `artifacts/plos-runtime/PLOS_GOAL.md`.

## Hard Scope

This skill is a control-plane and phase-gate skill. It does not authorize:

- PLOS runtime feature implementation outside an active `AMB-*` issue.
- PLOS-M00 execution unless the current task explicitly authorizes `AMB-608`.
- Branch creation unless the user or active issue explicitly changes branch policy.
- Required cloud LLM/core server dependencies.
- Private user data in R2 or public Source Atlas objects.
- Release, TestFlight, App Store, device, accessibility, privacy/legal, or performance claims without evidence.

## Required Read Order

Before any non-trivial PLOS task:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. `artifacts/plos-runtime/PLOS_GOAL.md`
10. `artifacts/plos-runtime/PLOS-run-state.md`
11. `artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.md`
12. `artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.md`
13. `artifacts/plos-runtime/PLOS_PHASE_GATES.md`
14. The active Linear issue, resolved by `AMB-*` identifier

For Source Atlas-adjacent phases, also read:

- `artifacts/source-atlas-factory/SAF_GOAL.md`
- `artifacts/source-atlas-factory/SAF_HARDENING_PLAN.md`
- `.agents/skills/source-atlas-factory/SKILL.md`

## Linear Identifier Law

PLOS labels are local labels only.

- Use `AMB-*` for Linear reads, writes, comments, status changes, and closeouts.
- Never use `PLOS-M##` or `PLOS-###` as the Linear issue identifier.
- Resolve a child PLOS label to `AMB-*` before reading, editing, commenting, or closing out.
- Record child bindings in the active packet/run-state before work starts.
- If no `AMB-*` binding exists, stop Red.

The phase map lives in:

- `artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.json`
- `artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.md`

## Execution Procedure

1. Confirm current branch and repo status.
2. Capture the current `BASE_SHA` before source-changing work.
3. Resolve the active phase to `AMB-*`.
4. Resolve any child label to `AMB-*`.
5. Run `scripts/codex/program-preflight.sh plos`.
6. Run `scripts/codex/program-phase-gate.sh plos <phase>`.
7. Verify active source ownership before source edits.
8. Use the smallest sufficient patch for the active `AMB-*` issue.
9. Run focused validation and relevant reviewer prompts.
10. Validate closeout text with `python3 scripts/codex/linear-closeout-validate.py --program plos`.
11. Commit and push only scoped validated work.
12. Update Linear with evidence-backed status using the `AMB-*` identifier.

## Required Scripts

- `scripts/codex/plos-readiness-validate.py`
- `scripts/codex/source-atlas-readiness-validate.py`
- `scripts/codex/program-preflight.sh plos`
- `scripts/codex/program-phase-gate.sh plos <phase>`
- `python3 scripts/codex/linear-closeout-validate.py --program plos`
- `.agents/skills/plos-runtime-master-build/scripts/plos-preflight.sh`
- `.agents/skills/plos-runtime-master-build/scripts/plos-phase-gate.sh <phase>`

## Reviewers

Use read-only reviewer passes when the task touches governance, phase gates, Source Atlas, privacy, safety, UI/runtime behavior, or closeout. Reviewer prompts are in:

- `references/plos-reviewer-prompts.md`

Reviewer output must classify Green/Yellow/Red and cite files/evidence. Reviewers do not edit source unless a future task explicitly scopes them as implementers.

## Phase Order

Follow `artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json`.

M00 is first and remains blocked for owner review after this readiness hardening packet. M01 is blocked behind M00. M10 Golden Slice blocks broad runtime expansion. Later phases are blocked behind strict predecessor gates.

## Source Atlas Rules

For M04, M05, M06, and any phase that depends on Source Atlas:

- Reuse existing Source Atlas tools and artifacts before adding new ones.
- Source packs must have source binding, freshness, revocation, review, release receipt, and rollback.
- R2 is public-reference-only.
- Private user data in R2 is Red.
- Runtime eligibility is blocked until pack/seed/source authority gates are Green or accepted Yellow.

## Closeout Rules

PLOS closeout must include:

- Actual `AMB-*` issue(s), not only PLOS labels.
- Pushed branch and commit hash if pushed.
- Whether app source changed.
- Whether runtime features were implemented.
- Whether PLOS-M00 was executed.
- Validation commands and results.
- Red blockers and Yellow limits.
- Owner approval and release/readiness claim boundaries.
- Next recommended action.

Use `references/plos-closeout-template.md` and validate with:

```bash
python3 scripts/codex/linear-closeout-validate.py --program plos <closeout-file>
```

## Red Stops

Stop and report if any of these occur:

- PLOS label used as a Linear identifier.
- Missing `AMB-*` binding.
- Phase-order violation.
- Runtime feature implementation requested during readiness-only work.
- Private user data in R2/public Source Atlas material.
- Required cloud LLM/core server dependency.
- New dependency, telemetry, analytics, hosted CI, or write-capable MCP without explicit approval.
- Release, accessibility, privacy/legal, device, performance, or App Review claim without proof.
- App source/project changes during a docs/scripts/skills/artifacts-only packet.
