# Batch 36 — Post-2.0 Hardening 02 / Trust, Extensions, and External Surface Validation

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-34058953, AMB28-stale_or_unknown_active_status-47370957

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Status

Completed

## Goal

Validate and productize external and trust surfaces against the settled shell, closing truth gaps around share extension, App Intents, widgets, notifications, external routing, and platform-facing claims.

This batch is the second step of the post-2.0 whole-repo/app hardening wave. It should begin only after Batch 35 has stabilized shell truth and Plan canon recovery.

## In Scope

- share extension truth and productization
- App Intents truth and productization
- widgets, notifications, and external-routing validation
- platform-facing trust claims and external-surface truth reconciliation
- shell-aligned validation of external entry points

## Out Of Scope

- new intelligence systems
- speculative new platform surfaces or device programs
- broad shell redesign
- secondary-surface maturity work that belongs in Batch 37
- release-readiness consolidation work that belongs in Batch 38

## Dependency Rules

- do not start this batch until Batch 35 has settled shell truth
- validate external surfaces against the settled shell rather than a moving IA target
- keep the work focused on truth, trust, and productization
- do not pull the later UI/UX excellence wave into this batch

## Exit Criteria

- external surfaces are validated against the settled shell
- share extension and App Intents no longer live in product-truth limbo
- widgets, notifications, and external routes have truthful platform-facing claims
- major trust gaps across external surfaces are closed or explicitly downgraded in truth
- Batch 37 can productize weaker internal surfaces on top of a truthful shell and truthful external boundary

## Validation

- docs/control-file truth checks for touched planning files
- targeted external-surface verification appropriate to the eventual implementation scope
- do not mark this batch completed until platform-facing claims are validated truthfully

## Completion Rule

Batch 36 is complete only when external and trust surfaces are truthful, validated against the stabilized shell, and no longer depend on unresolved shell-level ambiguity.

## Completion Summary

- Centralized external-surface truth wording across Profile, previews, placeholders, and docs.
- Added a narrow Profile trust surface that reflects notification authorization without turning Profile into a broader integration center.
- Kept Share Extension explicitly unshipped in product copy and documentation.
- Shipped App Intents only as navigation-only shortcuts bounded to Today, Plan, and the Captures inbox.
- Preserved centralized routing through `AppExternalRouting` and the shared launch/bootstrap seam.
- Fixed the missing `ambitions://` URL registration so real OS-surface deep links can open the app.

## Validation Outcome

- Passed `xcodegen generate`.
- Passed native simulator build for `Ambitions`.
- Passed targeted external-surface/unit coverage, including routing, payload, snapshot, notification, Profile-truth, and App-Intent routing tests.
- Passed `AmbitionsUITests`, including canonical landing coverage for `ambitions://tab/plan` and `ambitions://captures/inbox`.
- Passed full `AmbitionsTests` (`340` tests, `0` failures) after rerunning the unit suite on its own following a killed runner caused by parallel test execution.
- Confirmed shared snapshot export in the App Group container and real OS-level `ambitions://` route registration with `simctl openurl`.

## Conservative Surfaces After Wrap-Up

- Widgets and Live Activity remain described as `Available in this build, pending Batch 36 validation`.
- Notifications remain described as `Available in this build, pending Batch 36 validation`.
- App Intents remain described as `Available in this build, pending Batch 36 validation` even though the navigation-only implementation shipped.

These surfaces stay conservative because full manual platform confirmation of widget rendering/tap behavior, Live Activity appear-update-end behavior, notification authorization UX in Profile, and App Shortcuts visibility/opening could not be completed reliably in this environment.

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
