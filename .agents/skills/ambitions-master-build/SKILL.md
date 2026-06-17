---
name: ambitions-master-build
description: Phase-gated Goal Mode control plane for the Ambitions Personal Life OS Runtime + Native iPhone App Master Build Linear project. Use for AMB-* issue binding, train gates, source-changing execution, reviewer prompts, closeout validation, no-false-Green reporting, and commit/push continuation on main.
---

# Ambitions Master Build

Use this skill for the Ambitions Personal Life OS Runtime + Native iPhone App Master Build Program.

This skill is subordinate to `docs/truth/*`, `AGENTS.md`, live source, current validation proof, and live Linear `AMB-*` issues.

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
9. `.codex/os/AMBITIONS_OPERATING_CONTEXT.md`
10. The active Linear issue, resolved by `AMB-*` identifier

## Product Guardrails

Preserve these invariants unless active truth and source proof are updated together:

- Persistent surfaces are `Today / Goals / Time / You`.
- Capture is global composer/overlay, not a tab/root destination.
- Motion is cross-surface behavior, not a tab/root destination.
- Proof / Source / Privacy / History / Receipts are inspectable trust details.
- Offline core app value works with no Ambitions Account and no network dependency.
- Ambitions Accounts are optional launch identity/entitlement infrastructure using Sign in with Apple and Google Sign-In.
- R2/Source Atlas is public/reference/freshness infrastructure, not a user-data backend.
- Hosted AI services and cloud LLMs are not core architecture.
- Plan/Profile/Captures/Pulse/Motion-tab/Capture-tab language is historical or compatibility context unless explicitly scoped.

Use canonical language from `PRODUCT_DESIGN_TRUTH.md`: `Start here`, `Recommended step`, `Start now`, `Open step`, `Step`, `Done`, `Still counts`, `Move it`, `Blocked`, `Waiting`, `Not needed`, `Protected`, `Review`, and `Undo`.

## Execution Procedure

1. Confirm branch is `main`, worktree state, baseline SHA, and remote `origin/main`.
2. Read the required authority stack and active Linear issue.
3. Resolve the next train label to an `AMB-*` issue using the issue map and live Linear.
4. Run the relevant program preflight/phase gate.
5. Before source edits, prove active source ownership and run required owner/parallel-implementation guards when source paths are touched.
6. Make the smallest sufficient source/control-plane change that satisfies the current `AMB-*` issue.
7. Run focused validation, reviewer passes where risk warrants, and closeout validation.
8. Update run-state, proof ledger, queue/map if Linear state changed, and issue report.
9. Commit scoped work on `main`, push to `origin/main`, record SHA, and update Linear with evidence-backed status.

## Closeout Rules

Every closeout must include the actual `AMB-*` issue, pushed SHA if pushed, app source status, runtime behavior status, validation commands/results, proof artifacts, Green/Yellow/Red status, Red blockers, Yellow limits, non-claims, rollback, and next train.

Account/R2/network closeouts must include offline-core status, account-auth proof status, entitlement proof status, and R2 boundary proof status.

Motion/Capture/root IA closeouts must include root-surfaces status, Capture-root status, Motion-root status, and compatibility-debt status.

## Red Stops

Stop and repair or report hard Red if:

- a train label is used as a Linear identifier
- no `AMB-*` binding exists for the active train
- branch is not `main`
- a source-changing issue lacks source ownership proof
- Motion is reintroduced as a root destination
- Capture is reintroduced as a root destination
- a fifth/sixth persistent surface appears
- Plan/Profile/Captures/Pulse returns as active top-level IA
- account sign-in is required for core local app value
- R2 is used outside public/reference/freshness boundaries
- hosted AI/cloud LLM becomes core runtime
- release, TestFlight, App Store, device, accessibility, privacy/legal, performance, account auth, R2, or App Review readiness is claimed without current proof
