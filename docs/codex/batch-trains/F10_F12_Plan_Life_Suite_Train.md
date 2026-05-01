# F10-F12 Plan Life Suite Train

Path: docs/codex/batch-trains/F10_F12_Plan_Life_Suite_Train.md
Status: Active batch train manifest

## Purpose
Auto-continue F10 to F11 on Green; stop before F12 if reflow architecture is unclear.

## Train Type
Product Train, conservative

## Allowed Auto-Continue Behavior
Codex may continue only on Green. Yellow and Red stop. Architecture trains are planning-only unless explicitly approved.

## Batch List
- F10 Plan Life Suite foundation
- F11 Day Shape / Week Shape
- F12 Reflow / Recovery / Decisions

## Owning Primitives
Golden Launch Loop primitives named by the active batch plan. F17 owns shell only after F01-F16.5 evidence is accepted.

## Owning Surfaces
Today, Capture, Plan, Goals, You, or Shell as named by the batch list. Do not add new top-level destinations.

## Dependencies
Read order: README.md; docs/README.md; docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md; docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md; docs/canon/Ambitions_3_0_Rebuild_Operating_Model.md; docs/canon/Ambitions_3_0_Primitive_Architecture.md; docs/canon/Ambitions_3_0_Product_Language_System.md; docs/codex/BATCH_REGISTRY.md; docs/codex/CONTEXT_INDEX.md. Validate prerequisite batches before executing.

## Allowed Files
Only target feature files, focused tests/previews, batch reports, run-state files, and active docs explicitly named by the batch prompt.

## Forbidden Files
`.github/workflows/**`, runtime dependency manifests unless explicitly approved, unrelated surfaces, release-claim docs except truthful reports, generated artifacts, and F17 implementation unless this is the F17 approved planning/implementation run.

## Validation Packs
Batch train gate pack, continuation/stop pack as applicable, architecture hygiene pack, feature file responsibility pack, SwiftUI state contract pack for feature state work, release claim pack for any release wording.


## Green Gate
Codex may continue automatically only when the working tree was clean before the batch or contains expected staged changes only; the batch stayed within allowed files; no forbidden files, workflow files, runtime dependencies, or unapproved product surfaces were touched; build and focused tests pass; touched-scope copy, privacy, accessibility, UI-test-contract, architecture, and file-responsibility checks are acceptable; run state and batch-train state are updated; a report is written; a commit is created; and the next prompt exists and matches the manifest.

## Yellow Stop
Codex must stop, write a stop report, and generate a repair or decision prompt for doc-QA advisory backlog, known unrelated UI-smoke failures, full-suite failure with focused tests passing, minor canon ambiguity, non-blocking link/copy backlog, small out-of-scope test drift, touched files broader than expected, optional tool absence, file-responsibility warnings, feature state files exceeding soft thresholds, or conditional checkpoint triggers such as F13.5/F16.5.

## Red Stop
Codex stops immediately for build failure, focused-test failure, forbidden files touched, `.github/workflows` touched, runtime dependency added, shell/routing changed outside scope, privacy-sensitive leakage, forbidden user-facing copy, task-width escalation without approval, persistence/deep-link/App Intent breakage, merge conflict or unclear dirty state, commit failure, untrustworthy validation, skipped required architecture hardening, or human escalation trigger.


## Commit Strategy
Path-limited staging. One commit per Green batch. Stop if commit fails.

## Final Report Path
`docs/audits/ambitions-3-0-f10-f12-plan-life-suite-train-report.md`

## Human Review Required
Required before skipped batches, Architecture Train implementation, workflow/dependency changes, release claims, privacy/memory ambiguity, or F17 implementation.
