# CS09 Compatibility Regression Repair Prompt

Status: Repaired Ambitions 4.0 compatibility batch; internally staged as CS09A/CS09B/CS09C after dry-run Red. CS09A and CS09B are docs/proof stages only; CS09C remains deferred until a named compatibility regression exists. Formal Ambitions 4.0 batch count remains `113`.

## Batch Identity

- Batch ID: `CS09`
- Name: Compatibility Regression Repair
- Compatibility action: repairs
- Candidate seam: files named by failed CS evidence
- Target: Repair classified compatibility regression only.
- Repaired staging: `CS09A` conditional regression target map and repair protocol, `CS09B` no-regression proof / parked repair evidence, `CS09C` actual repair only after a named regression target exists.

## Purpose

CS09 is a conditional repair batch. It may repair only a named compatibility regression with reproducible evidence, owner files, source truth, allowed repair boundaries, validation lane, and rollback path. If no named regression exists, CS09 must stop as accepted Yellow / parked rather than inventing repair work or converting deferred CS02C-CS06C retirements into regression scope.

## Source Truth Files To Read First

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/canon/Ambitions_Beyond_3_0_Compatibility_Seam_Retirement_Plan.md`
- `docs/codex/batch-trains/CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_TRAIN.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/skills/compatibility-migration-architect.md`

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- `rg -n "files|Profile|You|Insights|Habits|activeFocus|TodayFocus|\.focus|failed|rawValue|deepLink|widget|AppIntent|import|export" Native docs .codex || true`

Stop if predecessor CS gates are not Green or accepted Yellow, if the seam owner is unclear, if route/raw-value/persistence/external payload impact cannot be mapped, or if no named compatibility regression target exists.

## CS09A - Conditional Regression Target Map And Repair Protocol

Type: docs/protocol only.

CS09A creates or updates the conditional target template and records that CS09 cannot execute repair work without a named compatibility regression.

Every CS09 repair target must include:

- affected seam
- expected preserved behavior
- actual broken behavior
- source-truth reference
- failing test or reproducible evidence
- impacted files/families
- allowed repair boundaries
- validation lane
- rollback plan

CS09A acceptance:

- CS09 is documented as conditional repair work.
- Deferred CS02C-CS06C retirements are explicitly excluded from regression repair scope.
- No production Swift, tests, routes, raw values, persistence, accessibility identifiers, app behavior, dependencies, workflows, signing, or release files change.

## CS09B - No-Regression Proof / Parked Repair Evidence

Type: docs/proof only by default.

CS09B inspects the current CS09 Red report, CS02-CS06 deferred items, batch registry/current run state, compatibility ledgers/reports from CS03-CS06, and focused compatibility test results already recorded.

CS09B must classify:

- actual named regression: yes/no
- deferred retirement: yes/no
- implementation backlog: yes/no
- docs QA backlog: yes/no
- human/platform proof backlog: yes/no
- unsafe invented scope risk: yes/no

If no named regression exists, CS09B marks CS09 accepted Yellow as a parked conditional repair batch with no current repair target. CS09B must not add tests unless repo evidence proves a proof-only test is required.

## CS09C - Actual Compatibility Regression Repair

Type: implementation only if a named compatibility regression target exists.

Do not execute CS09C unless a target map names the affected seam, expected behavior, broken behavior, source truth, failing evidence, impacted files, allowed repair boundary, validation lane, and rollback plan.

If no named regression exists, CS09C is deferred as accepted Yellow and the global train may continue according to the updated order after CS09A/CS09B evidence is committed.

## Allowed Files

- CS09A/CS09B: `docs/**`, `.codex/**`, and train/status docs only.
- CS09C: seam owner files discovered and named in the target map.
- CS09C: focused tests for legacy and replacement behavior.
- Compatibility fixtures for old routes, raw values, imports/exports, widgets, App Intents, shortcuts, and persistence views when applicable
- `docs/**` and `.codex/**` for maps, reports, traceability, and evidence

## Forbidden Files

- `.github/workflows/**`
- Dependency manifests, lockfiles, signing/project release config
- Deleting legacy values, routes, payload decoders, fixtures, or migration adapters before proof exists
- Product behavior expansion, visual redesign, broad cleanup, AOS implementation, release claims, backend/sync/account/model/runtime work
- Production Swift during CS09A/CS09B.
- Tests during CS09A/CS09B unless a specific proof-only test is justified by repo evidence.

## Implementation Boundary

This batch may map, prove, repair, hand off, or retire only a named regression target. A repair action requires target map, route/deep-link review, schema/persistence review, widget/App Intent/Shortcut review, import/export review, preview fixture review, focused tests, rollback path, and release-claim review before changing behavior. Deferred retirements are not repair targets.

## Required Non-Goals

No opportunistic renaming, no broad product language sweep, no schema migration without explicit migration gate, no platform-readiness claim, no release-readiness claim, no deletion before proof, no invented regression target, and no conversion of CS02C-CS06C deferred retirements into repair scope.

## Required Validation Commands

- `git status --short`
- Focused compatibility tests named by the seam map
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- `scripts/build-local.sh || true` when app code changed
- `git diff --check`

## Required Evidence Outputs

- Compatibility seam report with old value, replacement value, affected routes, payloads, persistence/import/export impact, external surfaces, tests, rollback, and release-claim status
- Updated compatibility registry and traceability matrix
- Registry/context/run-state update after evidence
- Failure-forensics report for any unclassified compatibility issue

## Green / Yellow / Red Criteria

Green: named regression target exists, repair map is complete, old payloads still open, focused compatibility proof passes, rollback exists, and no release/platform claim is introduced.

Yellow: advisory docs/tooling backlog; a nonblocking legacy seam remains intentionally preserved with owner and review date; or no named compatibility regression exists and CS09 is parked as a conditional repair batch.

Red: route/deep-link uncertainty, raw-value uncertainty, widget/App Intent/Shortcut uncertainty, import/export uncertainty, persistence/schema uncertainty, accessibility identifier mismatch, public copy regression, deletion before proof, release claim ambiguity, or an attempt to repair without a named regression target.

## Stop Conditions

Stop on any Red, missing seam owner, missing regression target, legacy payload failure, unclassified UI/test failure, migration uncertainty, missing rollback path, or request to retire adjacent seams.

## Rollback / Repair Expectations

Preserve old values until proof is Green. Repair through CS09 only after classifying the compatibility failure. If no compatibility failure exists, park CS09 as accepted Yellow. Do not remove fallback decoders or route aliases without documented retirement evidence.

## What This Batch Must Not Claim

It must not claim all compatibility seams are retired, CS02C-CS06C are complete, external platform readiness, App Store/TestFlight/device readiness, or AmbitionsOS implementation.

## What This Batch Does Not Prove

It does not prove physical-device behavior, signed archive validation, public accessibility conformance, or future platform behavior beyond the focused seam evidence.

## Commit Message Recommendation

CS09A/CS09B: `Repair CS09 conditional compatibility regression scope`

CS09C: `Repair named compatibility regression`

## Next Safe Prompt / Next Gate

Continue only after CS09 is Green or accepted Yellow, evidence is recorded, committed, and pushed. CS09C remains deferred until a named regression target exists.
