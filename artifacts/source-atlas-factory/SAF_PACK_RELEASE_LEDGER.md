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

No runtime-eligible packs are released by this Codex OS v2 install.
