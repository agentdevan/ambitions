# PFC18 App Intents / Shortcuts Implementation And Tests Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-38780476, AMB28-same_source_file_targeted_by_multiple_active_batches-42908187, AMB28-same_source_file_targeted_by_multiple_active_batches-50387371, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_source_file_targeted_by_multiple_active_batches-7658313, AMB28-same_source_file_targeted_by_multiple_active_batches-83544260, AMB28-same_source_file_targeted_by_multiple_active_batches-86062281, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Complete / Green as bounded App Intents source hardening and tests.
Date: 2026-05-06
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Owner: App Intents / External Actions / Privacy

## Purpose

Implement or repair the existing App Intents and Shortcuts surface so the
PFC17 launch contract remains bounded, privacy-safe, source-testable, and
honest about proof limits.

PFC18 does not approve new top-level destinations, hidden mutation,
destructive shortcut actions, Spotlight indexing of user life content,
entitlements, signing, project wiring, release readiness, App Store readiness,
TestFlight readiness, physical-device proof, public accessibility conformance,
legal/privacy compliance, or final privacy-label truth.

## Source Truth

Read before execution:

- `docs/canon/Ambitions_App_Intents_Shortcuts_Spotlight_Strategy.md`
- `docs/audits/pfc17-app-intents-shortcuts-spotlight-strategy-report.md`
- `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift`
- `Native/Ambitions/App/AppIntentLaunchRouter.swift`
- `Native/Ambitions/Services/ExternalActionCommandService.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalCreationContracts.swift`
- `Native/Ambitions/App/AppExternalRouting.swift`
- `Native/AmbitionsTests/App/AppIntentRoutingTests.swift`
- `Native/AmbitionsTests/App/ExternalActionCommandServiceTests.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceActionPayloadTests.swift`

## Allowed Files

- `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift`
- focused App Intent / external action routing tests
- PFC18 prompt/report and train-state docs

## Forbidden Files

- Entitlements, signing, provisioning, project files, workflows, dependencies,
  persistence schema, sync/account/backend runtime, AI/LDI runtime, new
  top-level destinations, new Spotlight/CoreSpotlight indexing, destructive
  inline mutation, App Store Connect state, release/legal/privacy readiness
  claims, and physical-device/public accessibility claims.

## Required Acceptance

- Public App Intent launch candidates stay limited to the PFC17-approved
  route-opening and review surfaces.
- Compatibility destinations stay available only as internal route
  compatibility, not widened public launch truth.
- Text capture trims local input, queues local review through Capture, and
  does not echo private text in the success dialog.
- Mutation-capable shortcuts require in-app confirmation and receipt posture.
- App Intent deep links keep `origin=app_intent` evidence.
- Build/test evidence proves the existing App Intents metadata still compiles.
- Real Shortcuts app, Siri, Spotlight, device, and rendered accessibility proof
  remain Yellow-owned.

## Required Validation

Run:

- `git status --short`
- `git diff --check`
- focused App Intent / external-action tests
- `scripts/build-local.sh`
- relevant CQS scans `|| true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Closeout

Close Green if scoped source behavior is implemented and tested, build proof
passes, no forbidden files are touched, and remaining Shortcuts/Siri/Spotlight/
device/App Store proof is explicitly Yellow-owned.

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
