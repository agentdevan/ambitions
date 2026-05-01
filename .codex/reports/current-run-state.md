# Current Run State

- current task: F17 Shell/Meridian planning prompt preparation
- task size: M
- active mode: Product Train closeout / F17 planning handoff
- active primitive: Shell/Meridian planning only
- active surface: App shell planning, routing ownership, feature boundary handoff
- active context pack: Ambitions 3.0 source stack plus F15-F16-F16.5 train manifest, UI Test Contract, SwiftUI State Contract Architecture Standard, Product Language System, F16 report, and known architecture backlog
- active skill: phase-executor plus repo-truth-enforcer
- active operations: batch-train-final-closeout; F17 planning handoff
- active validation packs: base-build-test-pack; copy-guard-pack; privacy-trust-pack; accessibility-pack; architecture-scan-pack; doc-QA advisory pack
- docs read: Batch Train Orchestrator; F15-F16-F16.5 train prompt and manifest; Product Language System; UI Test Contract; F15 report; F16 report; F16.5 report
- files allowed for next batch: F17 planning docs/reports only unless explicitly approved for implementation
- files forbidden: Shell/Meridian implementation; product behavior rewrites; UI test deletion without replacement or documented retirement; .github/workflows/**; runtime dependency manifests; release-readiness claims
- accepted Yellow reason: doc QA advisory backlog unchanged; known UI smoke readiness failures unchanged; pre-existing large-file warnings remain unless current F16.5 scope worsens or must resolve them; `activeFocus`/`Profile`/`Insights`/`Habits` retained only as documented compatibility seams
- resume reason: F12-F16 implementation train continuation
- previous stop point: F12 architecture clarity gate
- F16 status: Green; committed next
- F16.5 status: Green, planning/checkpoint hardening complete
- next prompt: F17 Shell/Meridian planning only; do not implement Shell/Meridian without explicit approval

## F16 Closeout

- F16 gate result: Green.
- Modernized brittle UI tests to assert active shell, Goals, Goal Detail, and Plan product contracts.
- Retired stale layout/detail expectations with documented replacements; no UI tests were deleted.
- Validation: build PASS on iPhone 17; focused modernized UI lane PASS, 7 tests; touched UI-test copy guard PASS; architecture scan advisory only; doc QA advisory/PARTIAL; `git diff --check` PASS.
- F16.5 is triggered because the architecture scan still reports broad feature-boundary and extraction-required risks before F17 planning.

## F16.5 Closeout

- F16.5 gate result: Green, planning/checkpoint hardening only.
- Architecture scan risks were reviewed and documented without broad behavior-preserving extraction.
- F17 planning may proceed; F17 implementation is not approved by this train.
- Remaining large-file risks are recorded in the F16.5 report.
- Final `scripts/test-local.sh || true` reached the known full UI smoke failure class: 29 UI tests run, 7 failures.

## F15 Closeout

- F15 gate result: Green.
- Migrated active `startFocus` to `startStepSession` while preserving raw command value `start_focus`.
- Migrated active `bestNextMove` to `recommendedStep` in Today state/projection/tests.
- Migrated active `capturesInbox` to `captureInbox` while preserving deep-link, App Intent, external payload, share extension, widget, and notification wire values.
- Preserved `activeFocus`, `Profile`, `Insights`, and `Habits` as documented compatibility seams.
- Validation: build PASS on iPhone 17; command tests PASS, 16 tests; routing/App Intent tests PASS, 46 tests; `TodayViewModelTests` PASS, 32 tests; migration scan PASS for `startFocus`, `bestNextMove`, and `capturesInbox`; architecture scan advisory only; `git diff --check` PASS.

## F14 Closeout

- F14 gate result: Green.
- You/Profile memory controls now expose explicit personalization consent state.
- Consent labels include local-record source, sensitive-memory approval posture, no-hidden-memory posture, and user ownership.
- F14 stayed inside the existing You/Profile trust-memory seam and added no hidden memory behavior.
- Validation: build PASS on iPhone 17; focused `ProfileFeatureServiceTests` PASS, 16 tests, 0 failures; architecture scan advisory only; copy guard found existing/internal failure-state terms only; `git diff --check` PASS.

## F13.5 Checkpoint

- F13.5 gate result: Green.
- Goals owns Goal Mission Control, goal-local proof/status display, path/lane ownership, and goal-local source labels.
- You/Trust owns `What Ambitions Knows`, memory/source/freshness visibility, personalization consent, correction/deletion/review controls, and sensitive-memory approval boundaries.
- Evidence/Proof owns receipt/proof hierarchy and proof semantics.
- F13.5 added no product behavior.
- F14 may proceed if it stays inside the existing You/Profile trust-memory seam.

## Gate

- F13 gate result: Green.
- F13.5 gate result: Green.
- F14 gate result: Green.
- F15 gate result: Green.
- F16 gate result: Green.
- F16.5 gate result: Green.
- stop condition: none.
- next phase: final train report and F17 planning prompt.
- last checkpoint: F16.5 report/tracking updated.
