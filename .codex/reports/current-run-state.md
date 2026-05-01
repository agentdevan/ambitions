# Current Run State

- current task: F16 UI Test Modernization
- task size: M
- active mode: Product Train / resumed Ambitions 3.0 implementation train
- active primitive: UI Test Modernization
- active surface: UI test contract and existing smoke coverage
- active context pack: Ambitions 3.0 source stack plus F15-F16-F16.5 train manifest, UI Test Contract, Product Language System, F15 report, and known full UI smoke failure backlog
- active skill: phase-executor plus repo-truth-enforcer
- active operations: batch-train-gate-protocol; F15 closeout; F16 readiness
- active validation packs: base-build-test-pack; copy-guard-pack; privacy-trust-pack; accessibility-pack; architecture-scan-pack; doc-QA advisory pack
- docs read: Batch Train Orchestrator; F15-F16-F16.5 train prompt and manifest; Product Language System; UI Test Contract; F15 report
- files allowed for next batch: Native/AmbitionsUITests; focused UI-test support code only if required; docs/codex; docs/audits; .codex/reports/current-run-state.md; .codex/reports/current-batch-train-state.md
- files forbidden: Shell/Meridian implementation; product behavior rewrites; UI test deletion without replacement or documented retirement; .github/workflows/**; runtime dependency manifests; release-readiness claims
- accepted Yellow reason: doc QA advisory backlog unchanged; known UI smoke readiness failures unchanged; pre-existing large-file warnings remain; `activeFocus`/`Profile`/`Insights`/`Habits` retained only as documented compatibility seams
- resume reason: F12-F16 implementation train continuation
- previous stop point: F12 architecture clarity gate
- F16 status: may proceed after F15 Green

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
- stop condition: none.
- next phase: commit and push F15, then start F16.
- last checkpoint: F15 report/tracking updated.
