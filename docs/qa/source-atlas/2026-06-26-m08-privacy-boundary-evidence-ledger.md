# M08 Privacy Boundary Evidence Ledger

Status: Green for scoped source/test proof; no account readiness, R2 upload, production promotion, or release privacy certification claimed.
Train: Source Atlas Implementation Train 04, M08.
Issues: AMB-1359, AMB-1360, AMB-1361, AMB-1362, AMB-1363.

## Scope Completed

- No-private-graph egress audit model added at `Native/Ambitions/Core/Runtime/SourceAtlasNoPrivateGraphEgressAudit.swift`.
- Cache/log/object-key privacy boundary model added at `Native/Ambitions/Core/Persistence/SourceAtlasPublicArtifactPrivacyBoundary.swift`.
- Local storage/cache separation proof and account/cache boundary decisions added in the same public artifact privacy boundary model.
- Focused tests added under `Native/AmbitionsTests/Runtime/` and `Native/AmbitionsTests/Persistence/`.

## Product Law Preserved

- Source Atlas remains public/reference/freshness infrastructure only.
- Source Atlas cache remains separate from Private Life Runtime storage.
- R2/public manifests and object keys are modeled as public/reference artifact locations only.
- No R2 upload was implemented.
- No account-required core behavior was added.
- Account export/reset/sign-out/delete-account behavior is a boundary contract only; no provider flow readiness is claimed.
- Runtime composition remains local-only.

## Proof Artifacts

- No-private-graph audit model: `Native/Ambitions/Core/Runtime/SourceAtlasNoPrivateGraphEgressAudit.swift`
- No-private-graph audit tests: `Native/AmbitionsTests/Runtime/SourceAtlasNoPrivateGraphEgressAuditTests.swift`
- Cache/log/object-key boundary model: `Native/Ambitions/Core/Persistence/SourceAtlasPublicArtifactPrivacyBoundary.swift`
- Cache/log/object-key, storage, and account/cache tests: `Native/AmbitionsTests/Persistence/SourceAtlasPublicArtifactPrivacyBoundaryTests.swift`
- Privacy manifest inspected by tests: `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`

## Focused Validation

- `scripts/ambitions-xcode-test-focused.sh --batch SOURCE_ATLAS_TRAIN04_FOCUSED --only-testing AmbitionsTests/SourceAtlasNoPrivateGraphEgressAuditTests --timeout 15m --kill-after 60s`
  - Passed; 2 tests.
  - Summary: `.codex/xcode-summaries/SOURCE_ATLAS_TRAIN04_FOCUSED/20260626T203438Z-AmbitionsTests-SourceAtlasNoPrivateGraphEgressAuditTests-15519-11519/focused-test-summary.json`
- `scripts/ambitions-xcode-test-focused.sh --batch SOURCE_ATLAS_TRAIN04_FOCUSED --only-testing AmbitionsTests/SourceAtlasPublicArtifactPrivacyBoundaryTests --timeout 15m --kill-after 60s`
  - Passed; 4 tests.
  - Summary: `.codex/xcode-summaries/SOURCE_ATLAS_TRAIN04_FOCUSED/20260626T203510Z-AmbitionsTests-SourceAtlasPublicArtifactPrivacyBoundaryTests-16360-31296/focused-test-summary.json`

## Validation Command Ledger

- `git diff --check`: passed.
- `bash scripts/ci/ambitions-pr-review-local.sh --continue`: passed; 16 checks passed, 0 failed.
- `python3 scripts/ambitions-green-standard-audit.py`: passed; no disallowed architecture-as-UI strings found in active primary UI source.
- `python3 scripts/source-atlas-boundary-audit.py`: passed; 40 targets.
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py`: passed.
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests`: passed; 41 tests.
- `scripts/ambitions-xcode-build-for-testing.sh --batch green-standard`: passed.
  - Summary: `.codex/xcode-summaries/green-standard/20260626T213532Z/extract/summary.json`
- Focused native privacy tests listed above passed.
- Privacy boundary scan inside the local PR review stack reported advisory hits for review-context copy and local-first settings copy, then passed with explicit non-claim review.

## Privacy Findings Covered

- Audit fails on private runtime markers in request shapes, cache metadata, object keys, log lines, fixtures, and inspection details.
- Forbidden markers include goal/capture text, schedule/capacity references, Life Capital, proof payloads, receipt payloads, private graph IDs, account secrets, user IDs, inferred priorities, behavior history, personal context, final schedules, and Step lists.
- Public artifact object keys are constrained to `source-atlas/public/{channel}/{packID}/{versionID}/{sha256}.json`.
- Log records and cache metadata expose source pack/freshness/hash/status fields only.
- Source Atlas cache namespace is documented as public/reference artifact cache, separate from local Private Life Runtime storage.
- Export/reset/sign-out/delete-account boundary decisions preserve account/cache separation without claiming account provider readiness.

## Proof Ceiling

- This is source/test proof for privacy boundaries.
- No network packet capture, R2 bucket audit, production account provider flow, App Store privacy review, legal signoff, device storage forensic sweep, or release privacy certification is claimed.
- No known issue closure, parent feature closure, project closure, M09 validation/release evidence, or M10 closeout is claimed.

## Known Risks

- Boundary models do not implement provider-side account export/delete flows.
- Tests prove modeled request/cache/log/object-key/privacy boundaries; they do not prove production R2 deployment configuration because no R2 upload or promotion is in scope.

## Rollback Plan

- Revert `Native/Ambitions/Core/Runtime/SourceAtlasNoPrivateGraphEgressAudit.swift`, `Native/Ambitions/Core/Persistence/SourceAtlasPublicArtifactPrivacyBoundary.swift`, and the related M08 tests.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Core/Runtime/`, `Core/Persistence/`.
- Files moved or created: new privacy egress and public artifact boundary files and tests listed above.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt: none for this scoped train.
- Next repair train if debt remains: none.
- Confirmation: no equivalent folder/path interpretation was used.
