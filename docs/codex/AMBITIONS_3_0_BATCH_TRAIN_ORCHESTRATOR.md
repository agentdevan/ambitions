# Ambitions 3.0 Batch Train Orchestrator

Path: docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md
Status: Active Codex operating canon

## Purpose
The Batch Train Orchestrator lets Codex execute related Ambitions 3.0 batches as a gated train while preserving source truth, batch history, architecture health, privacy/trust posture, and release-claim discipline.

Batch trains exist because some Ambitions work is safer when sequenced with shared context, validation, and checkpointing. They are not permission to run a mega-batch. A train continues only when every gate is Green.

## Allowed And Forbidden Use
Allowed trains have a current manifest, clear prerequisites, bounded surfaces, defined role reviews, explicit validation packs, and per-batch commits. Forbidden trains combine unrelated primitives, broad visual redesign plus behavior, dependency changes plus implementation, persistence migration plus UI rewrite, shell replacement plus test modernization, or release claims plus unfinished implementation.

## Train Sizes
- Micro Train: two tiny docs/copy batches; no app code; safe to auto-continue on Green.
- Standard Train: two to three tightly coupled implementation batches in one surface or journey; continue only on Green.
- Product Train: three to five batches across one product loop; checkpoint after every batch; stop on Yellow or Red; final report required.
- Architecture Train: model, routing, persistence, shell, or large refactor changes; planning only by default; implementation requires explicit approval.
- Quality Train: cleanup, refactor, test modernization, doc QA, or legacy language work; auto-continue only if behavior-preservation tests stay Green.
- Release Train: handoff, release, App Store, TestFlight, security, privacy readiness; no auto-continue without strict evidence gates.
- Forbidden Train: unrelated primitives, broad redesign plus behavior, dependency changes plus product implementation, persistence migration plus UI rewrite, shell replacement plus test modernization, release claim plus unfinished implementation.

## Train Risk Classes
- Low: docs/copy only with no behavior claims.
- Medium: one surface, additive state/projection/UI work, focused tests available.
- High: multi-surface product loop, privacy/trust implications, or test modernization.
- Critical: shell, routing, persistence, dependencies, release claims, or platform surfaces.

## Lifecycle
1. Preflight: check git state, branch, HEAD, last commit, task width, manifest, and prerequisites.
2. Load source truth: read the Ambitions 3.0 source stack plus target primitive/surface docs.
3. Initialize `.codex/reports/current-run-state.md` and `.codex/reports/current-batch-train-state.md`.
4. Execute exactly one listed batch.
5. Validate with required packs and role reviews.
6. Classify Green, Yellow, or Red.
7. On Green, report, commit, and continue only to the next manifest batch.
8. On Yellow/Red, stop and generate repair/resume material.
9. Finalize with a train report and conservative FAANG/release truth.

## Manifest Format
Each train manifest must name: train purpose; train type; allowed auto-continue behavior; batch list; owning primitives; owning surfaces; dependencies; allowed files; forbidden files; validation packs; Green gates; Yellow stop triggers; Red stop triggers; commit strategy; final report path; human-review requirement.


## Green Gate
Codex may continue automatically only when the working tree was clean before the batch or contains expected staged changes only; the batch stayed within allowed files; no forbidden files, workflow files, runtime dependencies, or unapproved product surfaces were touched; build and focused tests pass; touched-scope copy, privacy, accessibility, UI-test-contract, architecture, and file-responsibility checks are acceptable; run state and batch-train state are updated; a report is written; a commit is created; and the next prompt exists and matches the manifest.

## Yellow Stop
Codex must stop, write a stop report, and generate a repair or decision prompt for doc-QA advisory backlog, known unrelated UI-smoke failures, full-suite failure with focused tests passing, minor canon ambiguity, non-blocking link/copy backlog, small out-of-scope test drift, touched files broader than expected, optional tool absence, file-responsibility warnings, feature state files exceeding soft thresholds, or conditional checkpoint triggers such as F13.5/F16.5.

## Red Stop
Codex stops immediately for build failure, focused-test failure, forbidden files touched, `.github/workflows` touched, runtime dependency added, shell/routing changed outside scope, privacy-sensitive leakage, forbidden user-facing copy, task-width escalation without approval, persistence/deep-link/App Intent breakage, merge conflict or unclear dirty state, commit failure, untrustworthy validation, skipped required architecture hardening, or human escalation trigger.


## Checkpoints And Commits
Checkpoint after every batch. Commit each Green batch before continuing. Use path-limited staging. Do not continue if commit or push fails when the train requires pushed evidence.

## Validation Escalation
Focused tests are mandatory for touched scope. Build is mandatory for implementation batches. Full UI smoke is not required for every batch, but known failures must remain classified. A broader failure can be Yellow only when focused validation is Green and the failure is pre-existing or unrelated with evidence.

## Repair Prompt Generation
Every Yellow/Red stop writes a stop report and a copy/paste repair prompt that includes stop class, evidence, allowed files, forbidden files, validation commands, and exact resume condition.

## Rollback Rules
Prefer forward repair. Revert only Codex-owned changes from the current batch when the batch cannot be made safe, never unrelated user work. Do not use destructive git commands without explicit approval.

## Run-State And Compaction Recovery
Rebuild state from `.codex/reports/current-run-state.md`, `.codex/reports/current-batch-train-state.md`, latest train report, manifest, and git log. Never resume from chat memory alone.

## Role Reviews
Select FAANG role passes from task width. Product, design, iOS architecture, SwiftUI state, QA automation, privacy/trust, accessibility, build systems, release train, and Codex operating-system review are required for Product, Quality, Release, and Architecture trains.

## Architecture Hygiene Gates
Run architecture/file-responsibility checks when a batch touches feature state, projection, routing, or shared UI. Do not keep adding behavior to giant feature-brain files.

## SwiftUI State Contract Gates
Value state comes first. Feature-owned view states and deterministic projectors own projection. SwiftUI views render. Compatibility helpers must be explicit, small, and owned by a migration plan.

## File Responsibility Gates
400 lines means review responsibility. 700 lines means extraction recommended. 1000 lines means extraction required before adding more behavior unless justified. Five or more top-level state model families in one file means extraction recommended. Projection plus rendering plus compatibility plus tests-inferred copy in one file means extraction required.

## UI Test Contract Gates
UI tests protect product contracts, not fragile layout. Do not remove failing UI tests without replacement or retirement evidence. Modernize brittle tests only with canon-backed metadata.

## FAANG Handoff And Release Discipline
FAANG handoff remains PARTIAL unless the handoff gate is explicitly re-run and passes. Do not claim device verification, accessibility verification, TestFlight readiness, App Store readiness, final RC lock, or public release readiness without matching evidence.

## Human Escalation Triggers
Escalate for privacy ambiguity, memory consent ambiguity, shell replacement, dependency changes, workflow changes, persistence migration, release claim, unknown dirty state, or train skip proposal.

## Beyond 3.0 Continuity
Future-wave canon can extend Ambitions only through the Beyond 3.0 continuity rules. It must not silently supersede Ambitions 3.0 product identity or active source truth.
