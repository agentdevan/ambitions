# FCP09 Motion / Haptics / Reduced Motion Proof Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_source_file_targeted_by_multiple_active_batches-83544260, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748, AMB28-stale_or_unknown_active_status-72879121

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Role

You are operating as the Ambitions FCP09 shared design-system implementation
agent.

## Batch

FCP09 — Motion / Haptics / Reduced Motion Proof

## Source Truth

- `docs/canon/Ambitions_10_10_Flagship_Completion_Plan.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`
- `docs/audits/si12-interaction-motion-haptics-system-report.md`
- `docs/audits/dav10-adaptive-motion-reduce-motion-state-transitions-report.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_Source_Truth_Packet.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_Final_File_Boundary_Approval.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`

## Scope

Add object-specific motion and haptic policy proof for:

- Start Here
- Reality Rail
- Receipt Drawer
- Source Fold
- MissionControlTimeSpine
- Action Closure Diamond
- LifeShape Map
- Capture Atmosphere Composer

## Allowed Files

- `Sources/Components/MotionPrimitives.swift`
- `Sources/Previews/InteractionMotionHapticsPreviews.swift`
- `Native/AmbitionsTests/App/InteractionMotionHapticsDesignSystemTests.swift`
- FCP09 audit/report docs
- train registry, context index, current-run-state, current-batch-train-state,
  global order, and FCP train docs needed for batch closeout

## Forbidden Files

- Top-level navigation/tab definitions
- Persistence/schema/sync/auth/network files
- AI/AOS/LDI runtime files
- CI/workflow/signing/entitlement files
- App Store, TestFlight, release, legal, privacy, or public accessibility claim
  files unless only recording claim boundaries in the audit report

## Acceptance

- Each flagship object has a policy with owner, motion token, state meaning,
  non-motion cues, Reduce Motion equivalent, and haptic boundary.
- No motion-only meaning.
- Haptics stay optional and user-initiated.
- Source, proof, privacy, receipt, Capture, LifeShape, and
  MissionControlTimeSpine source truth remain intact.
- No route/raw-value, persistence/schema, sync/account, AI/LDI runtime, release,
  legal/privacy, or public accessibility claims are introduced.

## Required Validation

- `xcodegen generate`
- Focused `InteractionMotionHapticsDesignSystemTests`
- `scripts/build-local.sh`
- `git diff --check`
- touched-doc trailing whitespace scan
- CQS advisory scans relevant to motion, drift, accessibility, privacy, and
  prompt-built smell
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Stop Conditions

Stop only for a true Hard Red: app build break without safe repair path,
route/raw-value compatibility break, persistence/schema risk, unsupported
release/legal/privacy/accessibility claim, severe product drift, or a user
decision required to preserve source truth.

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
