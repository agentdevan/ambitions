# PFC09 iCloud CloudKit Sync Strategy Decision Report
<!-- markdownlint-disable MD013 -->

Result: Green
Date: 2026-05-05
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Batch: PFC09 iCloud / CloudKit Sync Strategy Decision
Owner: Sync / Privacy

## Decision

Ambitions' current platform strategy is:

```text
Launch/current runtime remains explicit local-only.
No launch sync.
No account requirement.
No CloudKit, iCloud, server-backed, or backend sync claim.
Future sync provider selection is deferred until export, recovery, privacy,
security, legal, and user-comprehension prerequisites are satisfied.
```

This is a current strategy decision, not a permanent product refusal to sync.
The next implementation-safe stance is to keep all public and in-app truth
local-only until a future approved batch explicitly chooses Apple-first CloudKit,
server-backed sync, or indefinite local-only operation with evidence.

## Evidence

`docs/canon/DATA_LOCAL_SYNC_EXPORT.md` locks:

- Default posture is local-first.
- No account is required at launch.
- No launch sync.
- Sync later only after trust/export is strong.
- Export should exist before cloud sync.
- Product UI must not claim shipped sync/export before implementation.

`Native/Ambitions/Persistence/SyncCapabilityContracts.swift` implements only:

- `SyncBackendKind.localOnly`
- `SyncCapabilityAvailability.unavailable`
- `LocalOnlySyncCapability`

`Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift` proves the only
supported runtime posture reports local-only and unavailable.

`PortableExportManifest` excludes cloud sync or account data and says the
portable package can move local data without requiring an account or cloud sync.

PFC06-PFC08 evidence shows export/import exists at service level, but
user-facing You / Trust Center export/import and device backup proof are still
future-owned.

## Files Inspected

- `docs/canon/DATA_LOCAL_SYNC_EXPORT.md`
- `docs/canon/TRUST_PRIVACY_MEMORY.md`
- `docs/canon/Ambitions_Platform_Legal_And_Framework_Completion_Plan.md`
- `docs/audits/pfc06-schema-persistence-source-truth-report.md`
- `docs/audits/pfc07-migration-ladder-backward-compatibility-tests-report.md`
- `docs/audits/pfc08-corruption-recovery-backup-restore-plan-report.md`
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`
- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`
- `Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift`
- `Native/AmbitionsTests/Persistence/PortableSnapshotServiceTests.swift`

## Files Changed

- `docs/codex/batches/PFC09_iCloud_CloudKit_Sync_Strategy_Decision_Prompt.md`
- `docs/audits/pfc09-icloud-cloudkit-sync-strategy-decision-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Future Sync Options

| Option | Current Rating | Why | Prerequisites |
| --- | --- | --- | --- |
| Keep current local-only launch strategy | Green | Matches active canon and implemented runtime evidence. | Continue no-claim boundaries and export/recovery hardening. |
| Apple-first CloudKit private database | Yellow / deferred | Plausible future Apple-native path, but no container, zones, entitlements, conflict model, account-unavailable state, or device proof exists. | PFC10 contract, PFC11 implementation proof, PFC12 App Group review, PFC24-PFC25 privacy proof, human/platform approval. |
| Server-backed sync | Red / future decision | Would require account, backend, API, auth, legal/privacy/security, data processing, and business decisions not present in source truth. | Explicit product/legal/security/business approval, backend architecture, privacy policy/TOS, threat model, account UX, and migration plan. |
| Indefinite local-only operation | Yellow / future decision | Compatible with privacy and trust, but product/business tradeoff is not finalized by PFC09. | User decision and long-term backup/export posture. |

## No-Claim Boundary

Do not claim:

- iCloud sync exists.
- CloudKit private database exists.
- Account backup exists.
- Server sync exists.
- Sync conflict handling exists.
- Device restore is proven.
- App Store privacy labels or privacy policy are complete.
- Sync is release-ready.

Allowed current copy:

- `Ambitions is local-first in this build.`
- `Your Ambitions data stays local unless a future sync path is explicitly added.`
- `Export/import is the current service-level portability path.`
- `Sync is unavailable in the current local-only runtime.`

## Future PFC10 / PFC11 Guidance

Because PFC09 does not authorize a sync implementation, PFC10 should produce a
CloudKit schema/zone/conflict contract only as a future option unless a new
approval source explicitly selects CloudKit. PFC11 should either remain blocked
or close as a safe deferral unless PFC09/PFC10 prerequisites are later upgraded.

## Validation Commands Run

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/cqs-privacy-security-claim-scan.sh docs/codex/batches/PFC09_iCloud_CloudKit_Sync_Strategy_Decision_Prompt.md docs/audits/pfc09-icloud-cloudkit-sync-strategy-decision-report.md || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Validation Results

- `git diff --check`: Pass.
- Touched-doc trailing whitespace scan: Pass.
- CQS privacy/security claim scan: Pass with zero hits for the PFC09 prompt
  scan root.
- `scripts/run-doc-qa.sh || true`: Accepted Yellow advisory backlog. Lychee
  reported 650 OK and 0 errors. Existing repo-wide markdown and deprecated
  language advisories are not introduced by PFC09 production source changes.
- `scripts/batch-train-gate-check.sh || true`: Accepted Yellow dirty-tree hint
  before commit, expected while the PFC09 docs and train-state files are
  uncommitted.
- Build/test not run because PFC09 changed docs/train state only and did not
  touch source, tests, project files, entitlements, dependencies, or sync
  runtime.

## Hard Red Review

No Hard Red occurred. A future sync provider decision would require user/product
approval, but PFC09 can close Green because existing source truth authorizes the
current local-only/no-launch-sync decision and blocks implementation claims.

## Rollback Path

Revert the PFC09 commit to remove the docs-only prompt, audit report, and train
state updates. No production Swift, schema, entitlement, project, workflow,
dependency, or generated rollback is needed because none were changed.

## Next Eligible Batch

PFC10 CloudKit Schema / Zone / Conflict Model.
