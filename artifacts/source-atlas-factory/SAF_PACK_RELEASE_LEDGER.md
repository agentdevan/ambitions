# SAF Pack Release Ledger

Status: Active Source Atlas Factory ledger

## Required Fields Per Pack

| Field | Required Meaning |
|---|---|
| pack_id | Stable pack identifier. |
| source_binding | Source URL/document/container/provenance binding. |
| freshness | Freshness date, stale policy, and refresh owner. |
| revocation | Revocation state and rollback trigger. |
| risk_class | low/medium/high/sensitive with reason. |
| jurisdiction | Applicable region or `not applicable`. |
| review_state | unreviewed/reviewed/blocked/approved-by-owner with evidence. |
| signature_hash_state | hash/signature/checksum status. |
| runtime_eligibility | not eligible/candidate/eligible with gates passed. |
| release_receipt | artifact path and command evidence. |
| rollback_path | exact rollback/revocation path. |
| non_claims | implementation/release/privacy/legal claims not made. |

## Required Release Receipt Contents

Every released, staged, promoted, superseded, revoked, rolled back, repaired, or quarantined Source Atlas pack/seed/manifest event must carry a release receipt with:

- stable `receipt_id`, `schema_version`, timestamp, owning `AMB-*` issue, operation type, release ring, and creator role
- exact pack, seed, manifest, validation report, freshness, revocation, compatibility, rollback, and canary artifact ids when applicable
- immutable local paths or future R2 object keys, never mutable aliases as source truth
- source binding ids plus raw source, normalized source, extraction, pack payload, and manifest hashes when applicable
- signature/checksum state, signer id/trust state, and verification result
- validation report references for schema, source binding, duplicate, contradiction, freshness, revocation, risk, jurisdiction, private-data, seed coverage, no-hardcoded-Step, Step Quality preflight, compatibility, rollback, and receipt completeness gates
- review state, risk class, jurisdiction envelope, freshness state, revocation state, rollback link, revocation link, supersession link, and compatibility state
- explicit no-private-data confirmation for artifact bodies, object keys, metadata, logs, screenshots, Linear comments, and receipt body
- runtime eligibility result, defaulting to `not_eligible` until future owning gates prove otherwise
- explicit non-claims for implementation, live R2 writes, runtime consumption, production readiness, privacy/legal approval, release readiness, device/accessibility/performance proof, and security certification when not proven

No release receipt means no staged, released, R2-promoted, rollback-target, supersession-target, current-manifest, candidate-runtime-eligible, or runtime-eligible Green path.

No runtime-eligible packs are released by this Codex OS v2 install.
