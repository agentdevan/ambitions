# AFRI-030 Optional CloudKit Continuity Decision Gate Proof

Issue: AMB-382 / AFRI-030

## Scope

- Added `docs/adr/ADR-010-optional-cloudkit-continuity-decision-gate.md`.
- Expanded `docs/architecture/APPLE_NATIVE_SYNC_CLOUDKIT_READINESS_GATE.md` with the AFRI-030 schema, conflict, opt-in UX, off switch, privacy-copy, and proof-test gate.
- Preserved the current local-only runtime and release posture.

## Source Truth Inspected

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/audits/pfc09-icloud-cloudkit-sync-strategy-decision-report.md`
- `docs/canon/Ambitions_CloudKit_Schema_Zone_Conflict_Model.md`
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`
- `Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift`

## Acceptance Mapping

- Schema decision material: recorded in ADR-010 and linked to the PFC10 future CloudKit contract.
- Conflict model: review-first, no silent destructive overwrite, tombstones, conflict receipts, and SourceRecord / Receipt / ReplayTrace / You inspection boundaries.
- Opt-in UX and off switch: documented as user-initiated enablement, reversible pause/disable, local writes preserved, and account-unavailable states.
- Privacy copy: current allowed and forbidden copy documented.
- Proof tests: fixture plan lists local-only fallback, account unavailable, idempotent zones/subscriptions, record round trips, tombstones, conflicts, memory correction, export/import, privacy scans, and rollback.
- Implementation block: ADR and gate both block sync implementation unless privacy, migration, rollback, device, and owner approval are Green.

## Validation

- Pre guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-382 --prompt /tmp/AMB-382-AFRI-030-guard-prompt.md` passed Green after prompt repair.
- Post guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-382 --prompt /tmp/AMB-382-AFRI-030-guard-prompt.md --batch-type proof-only --changed-from HEAD ...` passed Green.
- Diff whitespace: `git diff --check` passed.
- Forbidden provider/tracking and unsupported sync-claim scan over touched docs passed with no matches.

## Proof Boundary

This is docs/proof/architecture evidence only. It does not claim iCloud entitlement setup, CloudKit container setup, account UI, sync runtime, cross-device sync behavior, privacy/legal approval, device proof, TestFlight readiness, App Store readiness, release readiness, or public accessibility proof.

## Rollback

Revert the AMB-382 commit to remove the ADR, readiness-gate addendum, and proof packet. No runtime rollback is needed because no production Swift, entitlements, project settings, dependencies, persistence schema, signing, or CloudKit container files changed.
