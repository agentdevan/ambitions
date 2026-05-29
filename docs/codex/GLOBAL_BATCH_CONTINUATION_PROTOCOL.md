# Global Batch Continuation Protocol

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite
> Dispositions: rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Ambitions 4.0 global Codex OS control; no queued train started
Date: 2026-05-02

## Purpose

This protocol defines when Codex may continue from one globally ordered batch to the next.

## Continue Only When

- Current batch is Green or accepted Yellow.
- Current batch is committed.
- Registry/context/run-state/evidence are updated where required.
- Current branch is clean after commit.
- Next batch prerequisites are satisfied.
- Next batch source truth is available.
- Next batch does not require human proof.
- Next batch does not require a separate approval phrase that is missing or not
  covered by current global 4.0 preauthorization.
- Train control allows continuation.
- Global order allows continuation.
- Batch scope remains manageable.
- Validation strength is Strong or Adequate for the current batch type.
- No Red is unresolved.
- No unsafe dirty worktree exists.

## Stop When

- Unresolved Red exists.
- Human proof is required.
- App Store Connect, device signing, hardware proof, external rendered proof, public accessibility proof, legal/privacy signoff, or production release decision is required.
- Batch would exceed safe scope.
- Next batch requires explicit user approval that is not covered by current
  global 4.0 preauthorization.
- Next batch changes train type from docs-only to code implementation and
  approval is not present through the global sequence prompt or a specific
  train phrase.
- Context is too stale to continue safely.
- Current branch is dirty in an unsafe way.
- Validation is Weak or Missing for an implementation batch.
- Codex cannot prove product quality was preserved.
- Expected source truth is missing.
- Global order and train manifest disagree in a way that affects safety.
- The next batch would touch forbidden files without explicit approval.

## Single-Batch Mode

Run only the next global batch, then stop. This is the default for risky, code, release, compatibility, top-level UI, AOS runtime, or human-proof work.

## Continuous Mode

Run multiple global batches in order only when the user says `Run Global Batch Sequence Until Blocked` and every batch remains Green or accepted Yellow after validation, repair, commit, and branch-cleanliness checks.

Continuous mode never allows continuation through unresolved Red.

Continuous mode has no arbitrary milestone or batch-count cap. Continue until a
real blocker appears: unresolved Red, weak or missing implementation
validation, human-only proof, unsafe state, missing source truth, forbidden
file drift, unsupported claims, or explicit user stop.

## Approval Phrase Handling

The exact phrase `Run Global Batch Sequence Until Blocked` may replace routine
train-specific continuation phrases only when the current user prompt
explicitly preauthorizes Ambitions 4.0 execution across the named trains. In
that mode, do not stop merely to ask for `Continue Release Evidence Closure`,
`Start PXOS Future-Canon Train`, `Start ME Train`, `Start CS Train`,
`Start Signature Interface Train`, `Start Product Depth Train`, or
`Start AOS Train`.

Global preauthorization does not replace proof. Stop for physical-device proof,
App Store Connect proof, TestFlight proof, signed archive distribution proof,
public accessibility conformance, legal/privacy signoff, product-owner visual
approval when required by the batch, final release decisions, external platform
proof Codex cannot perform, unresolved Red, weak implementation validation, or
unsafe state.

## Commit-After-Each-Batch Rule

Every batch gets its own commit. Do not combine multiple global batches into one commit. Do not start the next batch with uncommitted changes from the current batch.

## Human-Proof Stop Rule

Codex must stop and produce an operator checklist for human-only proof. It may document the plan and evidence gaps, but it must not fake, simulate, or claim the proof.

## Context-Staleness Stop Rule

Stop only when source truth, current branch state, validation status, or batch
manifest status remains stale or unclear after refresh. After compaction,
resume, or long-run context refresh, reload the 4.0 execution source truth, the
last completed batch report, and the next selected batch prompt before
continuing.

## Validation-Strength Stop Rule

Weak or Missing validation blocks implementation continuation. Docs-only work may continue with advisory validation only when the advisory is classified, noncritical, and does not hide Red.

## Signature Interface Continuation Rule

SI implementation continuation requires Strong implementation validation plus SI quality-gate evidence. Build success alone is not enough. Stop if a UI-changing SI batch lacks preview/state evidence, anti-generic UI review, visual QA notes, accessibility/Dynamic Type/VoiceOver review, reduced-motion evidence for motion work, file-size/component-boundary review, or release-claim safety review.

The global phrase `Run Global Batch Sequence Until Blocked` may carry execution into SI when SI appears in the global order and prerequisites are Green or accepted Yellow. It does not authorize fake human visual approval, physical-device proof, public accessibility conformance, App Store/TestFlight proof, signed archive proof, or release readiness.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
