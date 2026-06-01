# AFEP-014 Permissions Matrix

Batch: AFEP-014
Scope: Personal Vault and Permissions Center projection inside `You`

## Verified Surface

- `Native/Ambitions/Domain/YouModels.swift`
- `Native/Ambitions/Features/You/YouFeatureService.swift`
- `Native/Ambitions/Features/You/YouScreen.swift`
- `Native/AmbitionsTests/You/YouFeatureServiceTests.swift`

## Permission Rows

| Row | Storage | Export | Reset | Delete | Provenance | Privacy policy | Permission |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Personal defaults | Stored on this device | Summary export only | Reset in You | Delete requires confirmation | SourceRecord-backed profile state | Private by default | User-owned |
| Local learning signals | Stored on this device | Summary plus receipt labels | Reset in What Ambitions knows | Delete requires confirmation | SourceRecord / Receipt / ReplayTrace | Private by default | Review gated |
| Proof and receipts | Stored on this device | Summary export only | Reset in Receipts | Delete requires confirmation | Receipt-backed provenance | Summaries first | Inspect in Trust Center |
| Permission matrix | Status stored locally | Export status only | Revoke or re-request in system settings | Delete remains confirmation-gated | System authorization state | No silent writes | Permission-gated |
| Protected storage boundary | Local-only | Portable snapshot pending proof | Reset on device | Delete requires confirmation | SourceRecord / Receipt | No silent retention or export | Future-owned |

## Inspection and Control Map

- The Personal Vault projection is exposed through `What Ambitions knows` and `Trust Center`.
- The trust surface includes a Personal Vault row, a Personal Vault data-map row, and Personal Vault trust routes.
- The context vault includes a Personal Vault item so the surface remains inspectable inside existing `You` ownership.

## Validation Evidence

- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-014`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-014 --prompt prompts/batches/AFEP-014.md --batch-type source-changing --allow-yellow`
- `xcodegen generate`
- `make xcode-build-for-testing BATCH=AFEP-014`
- `make xcode-focused-test BATCH=AFEP-014 TEST=AmbitionsTests/You/YouFeatureServiceTests`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-014 --prompt prompts/batches/AFEP-014.md --changed-from 2e7f582ddcba413a62e6825e3b90b366009283e3 --batch-type source-changing --allow-yellow`
- `git diff --check`
- `scripts/ambitions-xcode-benchmark.sh --status`

## Boundary Notes

- This matrix records inspectable labels and permission boundaries only.
- It does not claim legal approval, release readiness, protected-storage completion, or screenshot proof.
