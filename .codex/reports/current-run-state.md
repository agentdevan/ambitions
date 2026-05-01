# Current Run State

- current task: F15 Legacy Identifier Migration
- task size: M
- active mode: Product Train / resumed Ambitions 3.0 implementation train
- active primitive: Legacy Identifier Migration
- active surface: Today / Capture / Plan / Goals / You routing and compatibility seams
- active context pack: Ambitions 3.0 source stack plus F15-F16-F16.5 train manifest, Product Language System, UI Test Contract, dependency policy, routing/App Intent compatibility, and F14 report
- active skill: phase-executor plus repo-truth-enforcer
- active operations: batch-train-gate-protocol; F14 closeout; F15 readiness
- active validation packs: base-build-test-pack; copy-guard-pack; privacy-trust-pack; accessibility-pack; architecture-scan-pack; doc-QA advisory pack
- docs read: Batch Train Orchestrator; F13-F14 train prompt and manifest; Evidence Hierarchy; Personalization Consent Model; Privacy Threat Model; Product Language System; F13 report; F13.5 report; F14 report
- files allowed for next batch: focused legacy identifier and compatibility seams required by F15; focused routing/App Intent tests; docs/codex; docs/audits; .codex/reports/current-run-state.md; .codex/reports/current-batch-train-state.md
- files forbidden: Shell/Meridian implementation; new product behavior; persistence/deep-link/App Intent compatibility breaks; .github/workflows/**; runtime dependency manifests; release-readiness claims
- accepted Yellow reason: doc QA advisory backlog unchanged; known UI smoke readiness failures unchanged; pre-existing large-file warnings remain; legacy/internal identifier debt now active only where F15 scope requires migration
- resume reason: F12-F16 implementation train continuation
- previous stop point: F12 architecture clarity gate
- F15 status: may proceed after F14 Green

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
- stop condition: none.
- next phase: commit and push F14, then start F15.
- last checkpoint: F14 report/tracking updated.
