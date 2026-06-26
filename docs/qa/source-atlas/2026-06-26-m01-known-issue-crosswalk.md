# Source Atlas M01 Known-Issue Crosswalk

Status: current crosswalk, no closure claimed  
Scope: M01 boundary/classification issues only  
Date: 2026-06-26

This crosswalk records how M01 implementation reduces boundary risk. It does not close known issues, parent features, release gates, R2 readiness, account behavior, or privacy/legal approval.

| Issue area | M01 evidence | Status ceiling | Follow-up |
|---|---|---|---|
| R2 could be misread as private user-data backend | `docs/platform/SOURCE_ATLAS_DATA_CLASSIFICATION_MATRIX.md`, `tools/source-atlas/foundry/boundary.py`, `tools/source-atlas/foundry/validator.py` | Source/tooling boundary implemented | App-side request/cache proof still required before R2 readiness claims |
| Private user context in request shapes | `request_shape_issues` in `tools/source-atlas/foundry/boundary.py`, `tools/source-atlas/fixtures/boundary/invalid/account-secret-request.json` | Foundry/audit rejection implemented | App network request review still required |
| Private graph terms in R2 object keys | `object_key_issues` in `tools/source-atlas/foundry/boundary.py`, `tools/source-atlas/fixtures/boundary/invalid/user-id-r2-object-key.json` | Foundry/audit rejection implemented | Stable-channel Worker/promotion proof still required |
| Goal/capture/schedule/proof/receipt leakage into packs | negative fixtures under `tools/source-atlas/fixtures/boundary/invalid/` | Foundry/audit rejection implemented | Broader source scans and app-side integration proof still required |
| User mini-pack confusion with public Foundry packs | `tools/source-atlas/fixtures/boundary/invalid/user-mini-pack-in-r2.json` and native M02 validator | Foundry/native value-boundary rejection implemented | Local mini-pack behavior remains local runtime scope, not M01 closure |

Known issues are not closed by this crosswalk.
