# Task 28 — External authority reconciliation

## Scope

Task 28 records the owner-approved terminal archival state for exactly these Linear entities:

- `AMB-1756` → `AMB-1705`
- `3fc613b3-dac0-4104-b323-5f26fb868645` → `96b93346-271d-46fc-beab-43ff7e286b5d`
- `ebbfb3c1-cd88-4a4d-a254-7bdd1c8a61f6` → `96b93346-271d-46fc-beab-43ff7e286b5d`

The owner approved Linear archival as the terminal deletion state. The user reported four bounded inbound-document rewrites and fresh rereads before that terminal state was accepted; this repository does not hold raw connector responses for those operations.

## Evidence and limitation

The available Linear connector could verify the named targets and bounded rewrites, but could not prove exhaustive backlinks across every rich-text and comment surface or perform permanent deletion. The terminal state is therefore **owner-approved archival**, not a claim of hard deletion or exhaustive connector coverage.

No Figma mutation, production-source change, protected-enforcement claim, or release claim is included.

## Canon reconciliation

- `linear-reconciliation.json` records the approved terminal archival disposition and preserves the original content digests as provenance.
- The Task 28 owner scope amendment rebinds `claim-dispositions.json` and only mandatory deterministic dependent projections needed to clear `CLAIM_DISPOSITIONS_STALE`.
- The completed Task 26 transition remains historical and is verified from immutable Git objects; subsequent Task 28 work cannot change that cutover evidence.

## Rollback

Repository rollback is `8aa2995144bfae935adb65c1f1aa55ecf984d7ab` before this Task 28 reconciliation bundle. Linear archival restoration, if required, uses the external service's archive restore capability and the preserved preimage packet.

## Claim ceiling

This report supports only: **owner-approved Task 28 terminal Linear archival for the exact three-entity scope**, once its exact review and deterministic checks complete. It does not independently verify external execution, prove permanent external deletion or exhaustive external backlink coverage, or prove protected enforcement, product/runtime/visual/accessibility/privacy/legal/device readiness, or Release Green.
