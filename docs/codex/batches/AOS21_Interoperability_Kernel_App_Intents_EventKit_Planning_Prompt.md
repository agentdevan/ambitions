# AOS21 Interoperability Kernel App Intents EventKit Planning Prompt

Status: Queued Ambitions 4.0 AmbitionsOS batch; not started; future canon only until implemented by evidence; blocked pending `Start AOS Train`.

## Batch Identity

- Batch ID: `AOS21`
- Name: Interoperability Kernel App Intents EventKit Planning
- Owning kernel: Interoperability Kernel
- Affected 3.0 primitive: Today / Goals / Capture / Time / You only where the train gate names a concrete surface
- Affected surface: external surfaces
- Dependency gate: depends on AOS16, AOS17, and interoperability privacy gates
- Implementation boundary: planning only; source verification required before platform implementation

## Purpose

Move exactly this batch's AmbitionsOS contract or implementation slice forward without widening Ambitions into a chatbot, generic productivity app, calendar clone, source-certification authority, or broad AI assistant. Preserve current Ambitions 3.0 behavior unless this batch explicitly owns a tested behavior change.

## Living Dream Architecture Hook

LDI hook: Interoperability may plan private iCloud/CloudKit and external intent boundaries only when owned; no entitlement/signing changes by implication.

## Source Truth Files To Read First

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/canon/AmbitionsOS_Index.md`
- `docs/canon/AmbitionsOS_Core_Architecture.md`
- `docs/canon/AmbitionsOS_Runtime_Contract.md`
- `docs/codex/AMBITIONSOS_AOS_TRAIN_CONTROL_SYSTEM.md`
- `docs/codex/AMBITIONSOS_AOS_BATCH_GATE_MATRIX.md`
- `docs/codex/AMBITIONSOS_AOS_INVARIANT_LEDGER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- `rg -n "AOS21|Interoperability Kernel|AmbitionsOS|release ready|App Store ready|TestFlight ready" docs .codex Native README.md AGENTS.md || true`

Proceed only on `main`, with a coherent worktree, no unclassified user changes in target files, and a Green predecessor gate recorded in the AOS dependency graph.

## Allowed Files

- `docs/**` and `.codex/**` for planning, reports, traceability, fixtures, and evidence.
- Future implementation files only when this exact batch explicitly scopes them after preflight and they belong to the owning kernel/surface. Name every implementation file before editing.
- Test files and preview fixtures that directly prove this batch's contract.

## Forbidden Files

- `.github/workflows/**`
- Dependency manifests and package manager lockfiles
- Signing, project release config, and entitlement changes unless a separately approved platform train owns them
- Persistence/schema files unless this batch is explicitly a schema/migration batch and has Green migration review
- External route, App Intent, widget, Live Activity, EventKit, CloudKit, StoreKit, sync, backend, account, telemetry, analytics, crash reporting, remote config, or AI API implementation unless a later approved train owns that capability
- Any new top-level navigation destination

## Ownership Target Or Discovery Rule

Primary owner: Interoperability Kernel. Before edits, produce a decision record listing the exact files this batch will touch, why the owner owns them, and which large-file, compatibility, privacy, performance, and release gates apply. If the owner file is not obvious, stop after discovery and write the decision record instead of guessing.

## Required Implementation Boundary

This batch may read typed local state relevant to Interoperability Kernel; it may produce typed contracts, tests, fixtures, projections, reports, or user-reviewable deltas only. Model output must not mutate the Life Graph. Source-sensitive facts must remain unverified until source evidence is attached. User-facing behavior is allowed only when the batch explicitly owns it and focused tests cover it.

## Non-Goals

- No chatbot tab, AI-first surface, productivity score, confidence percentage, or guaranteed-path wording.
- No release, App Store, TestFlight, physical-device, public accessibility, platform-readiness, or production-model claim.
- No backend, account, sync, telemetry, remote config, hosted AI, or bundled custom LLM pivot.
- No broad refactor, visual redesign, opportunistic cleanup, route/raw-value migration, or compatibility seam retirement.

## Required Codex OS Gates

- Required skills: `aos-train-orchestrator`, `aos-invariant-enforcer`, `runtime-contract-reviewer`, `validation-evidence-auditor`, `release-claim-truth-enforcer`, plus `Interoperability Kernel`-specific reviewers.
- Required review board: architecture board for all AOS batches; add product/privacy/performance/accessibility/release/maintainability/compatibility boards when the touched files or claims require them.
- Required validation packs: AOS dependency graph, invariant ledger, fixture coverage, model boundary, privacy projection, source-truth claim, release-claim boundary, plus focused proof for the affected surface.
- Required fixtures: name the fixture groups from `docs/codex/AMBITIONSOS_AOS_FIXTURE_STRATEGY.md` before implementation.
- Required evidence ledger entry: command, timestamp, log path when available, pass/fail/partial status, proof scope, and what the proof does not claim.
- Required traceability matrix update: canon requirement, owning kernel, code/test/fixture evidence, known gaps, and release-claim status.
- Required test impact matrix update.
- Required source-truth claim ledger update if the batch touches source-sensitive facts.
- Required privacy projection review if sensitive or external-surface data is involved.
- Required performance budget review if runtime, projection, model, cache, graph, or background work is involved.
- Required compatibility review if routes, raw values, widgets, App Intents, imports/exports, persistence, or external payloads are involved.
- Required maintainability review if touching large files or extraction candidates.
- Required release-claim review before any claim-language change.

## Validation Commands

Start focused, then broaden only if focused proof is Green:

- `git status --short`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- `scripts/swiftui-architecture-scan.sh || true`
- Focused tests named by the touched implementation files, if any
- `scripts/build-local.sh || true` when app code changes
- `git diff --check`

## Required Evidence Outputs

- Batch report under `docs/audits/` or the train-designated report path
- Evidence ledger entry
- Traceability matrix update
- Test impact matrix update
- Registry/context/run-state update after evidence, not before
- Failure-forensics report if any focused or broad proof is Red or unclassified Yellow

## Green / Yellow / Red Criteria

Green: predecessor gate is Green, only allowed files changed, focused proof passes, evidence is recorded, release claims remain bounded, and no invariant is violated.

Yellow: advisory docs/tooling backlog, optional tool absence, simulator/environment instability, or future-only gap is classified with no app behavior or claim risk.

Red: forbidden file touched, dependency/workflow/release config drift, unclassified validation failure, source-truth overclaim, privacy leak, hidden model mutation, compatibility uncertainty, performance budget violation, new top-level surface, or release/platform readiness claim without proof.

## Stop Conditions

Stop on Red, missing predecessor gate, dirty target files owned by someone else, unclear owner, untrusted validation, missing rollback path, release-claim ambiguity, privacy ambiguity, or a request to broaden beyond AOS21.

## Rollback / Repair Expectations

Preserve failing logs, classify the failure, revert only your own changes if rollback is required, do not weaken tests to pass, and open AOS29 repair only when the failure is classified and the train rules allow it.

## What This Batch Must Not Claim

It must not claim AmbitionsOS is implemented, that Ambitions has an on-device reasoning engine, that Calendar/Reminders replacement exists, that official requirements are verified, or that the app is release/App Store/TestFlight/device/accessibility/platform ready.

## What This Batch Does Not Prove

This batch does not prove physical-device behavior, public accessibility conformance, signed archive validation, App Store Connect validation, external-platform rendering, production model behavior, backend availability, or future AOS batch readiness beyond the next named gate.

## Commit Message Recommendation

`Run AOS21 Interoperability Kernel App Intents EventKit Planning`

## Next Safe Prompt / Next Gate

Proceed only to the next AOS batch named by `docs/codex/AMBITIONSOS_AOS_DEPENDENCY_GRAPH.md` after this batch is Green, committed, pushed, and recorded. Yellow or Red starts the repair/failure-forensics path instead of automatic continuation.
