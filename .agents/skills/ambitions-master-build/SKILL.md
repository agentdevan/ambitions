---
name: ambitions-master-build
description: Phase-gated Goal Mode control plane for the Ambitions Personal Life OS Runtime + Native iPhone App Master Build Linear project. Use for the new master-build project at Linear project ca716546-e3d4-4d5b-a399-03076ccba9ee, including AMB-* issue binding, train gates, source-changing execution, reviewer prompts, closeout validation, no-false-Green reporting, and commit/push continuation on main.
---

# Ambitions Master Build

Use this skill for the Ambitions Personal Life OS Runtime + Native iPhone App Master Build Program. This is the source-changing successor control plane for the new Linear project:

`ca716546-e3d4-4d5b-a399-03076ccba9ee`

The skill is subordinate to `docs/truth/*`, `AGENTS.md`, live source, current validation proof, and live Linear `AMB-*` issues. User authority may permit stale repo authority repair, but it does not permit false Green, unproven release/accessibility/privacy/device claims, unsafe privacy/backend/LLM drift, force-pushes, branch creation, or destructive history rewrites.

## Required Read Order

Before any non-trivial master-build task:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. `artifacts/ambitions-master-build/AMB_MASTER_GOAL.md`
10. `artifacts/ambitions-master-build/AMB_MASTER-run-state.md`
11. `artifacts/ambitions-master-build/AMB_MASTER_LINEAR_ISSUE_MAP.md`
12. `artifacts/ambitions-master-build/AMB_MASTER_EXECUTION_QUEUE.md`
13. `artifacts/ambitions-master-build/AMB_MASTER_PHASE_GATES.md`
14. `docs/codex/AMB_MASTER_GREEN_YELLOW_RED_REPORTING.md`
15. `docs/codex/AMB_MASTER_VALIDATION_REGISTRY.md`
16. `docs/codex/AMB_MASTER_PROOF_ARTIFACT_CONTRACT.md`
17. The active Linear issue, resolved by `AMB-*` identifier

## Linear Identifier Law

Use `AMB-*` issue identifiers for Linear reads, writes, comments, status changes, commits, reports, and closeouts.

Local train labels such as `M00.T01` are routing aliases only. Never use train labels as Linear identifiers. If an active train lacks an `AMB-*` binding, stop Red and refresh the issue map from Linear.

## Execution Procedure

1. Confirm branch is `main`, worktree state, baseline SHA, and remote `origin/main`.
2. Read the required authority stack and active Linear issue.
3. Resolve the next train label to an `AMB-*` issue using the issue map and live Linear.
4. Run `scripts/codex/program-preflight.sh amb-master`.
5. Run `scripts/codex/program-phase-gate.sh amb-master <phase>`.
6. Before source edits, prove active source ownership and run required owner/parallel-implementation guards when source paths are touched.
7. Make the smallest sufficient source/control-plane change that satisfies the current `AMB-*` issue.
8. Run focused validation, reviewer passes where risk warrants, and closeout validation.
9. Update run-state, proof ledger, queue/map if Linear state changed, and issue report.
10. Commit scoped work on `main`, push to `origin/main`, record SHA, and update Linear with evidence-backed status.
11. Continue to the next train without waiting for Linear once the control plane is complete and live issue state does not block execution.

## Required Scripts

- `scripts/codex/amb-master-readiness-validate.py`
- `scripts/codex/amb-master-repository-wiring-validate.py`
- `scripts/codex/program-preflight.sh amb-master`
- `scripts/codex/program-phase-gate.sh amb-master <phase>`
- `python3 scripts/codex/linear-closeout-validate.py --program amb-master`
- `bash scripts/codex/program-proof-index.sh amb-master`
- `.agents/skills/ambitions-master-build/scripts/amb-master-preflight.sh`
- `.agents/skills/ambitions-master-build/scripts/amb-master-phase-gate.sh <phase>`

## Source-Changing Guard

For source-changing issues, the closeout cannot be Green unless it reports:

- Champion coverage status and report.
- Parallel implementation pre/post status and report.
- Canonical owner extended.
- New implementation owners, if any.
- Runtime wiring gate status.
- Focused build/test/validator evidence for the changed behavior.

If a guard is unavailable or not applicable, state why and classify the result honestly. Do not turn missing source proof into Green.

## Reviewers

Use read-only reviewer passes when the task touches source architecture, runtime behavior, UI/accessibility, privacy/local-first boundaries, Source Atlas/R2, CloudKit, StoreKit, high-risk safety, release/compliance, or closeout proof.

Reviewer prompts live at:

- `references/amb-master-reviewer-prompts.md`

## Phase Order

Follow `artifacts/ambitions-master-build/AMB_MASTER_EXECUTION_QUEUE.json`.

Current live control-plane state from Linear:

- `AMB-1126` is Done and rebuilt Linear as the execution control plane.
- `AMB-1046` / `M00.T00` is the program umbrella and first local Goal Mode install/authority train.
- `AMB-1047` / `M00.T01` and `AMB-1048` / `M00.T02` follow before source-changing milestone expansion.

## Product Guardrails

Preserve these invariants unless active truth and source proof are updated together:

- Ambitions is premium native iPhone-first and local-first.
- Active IA is `Today / Goals / Time / Motion / You`.
- Capture is global Atmosphere Composer/action layer, not a tab.
- Motion is current; Pulse is stale.
- Plan is not top-level user-facing IA.
- Use `Start here`, `Recommended step`, `Start now`, `Open step`, `Step`, `Capture`, `Recover`, `Explain`, `Correct`, `Keep momentum`, `Shrink`, `Replace`.
- No required external/cloud LLM core path.
- No private user data in R2/public Source Atlas.
- No telemetry/tracking/hosted backend dependency without explicit policy gates and proof.

## Closeout Rules

Use `references/amb-master-closeout-template.md` and validate with:

```bash
python3 scripts/codex/linear-closeout-validate.py --program amb-master --scope child <closeout-file>
```

Every closeout must include the actual `AMB-*` issue, pushed SHA if pushed, app source status, runtime behavior status, validation commands/results, proof artifacts, Green/Yellow/Red status, Red blockers, Yellow limits, non-claims, rollback, and next train.

## Red Stops

Stop and repair or report hard Red if:

- a train label is used as a Linear identifier
- no `AMB-*` binding exists for the active train
- branch is not `main`
- a source-changing issue lacks source ownership proof
- privacy leak, data loss, migration failure, unsafe high-risk recommendation, purchase break, sync corruption, route dead end, inaccessible destructive flow, stale IA regression, invalid source trust, or runtime crash exists
- release, TestFlight, App Store, device, accessibility, privacy/legal, performance, or App Review readiness is claimed without current proof
- private user data enters R2/public Source Atlas or a required cloud LLM/backend becomes core runtime
