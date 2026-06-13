# R2 Release Receipt Template

Status: Green for AMB-973 staging template scope; not a production release receipt.
Date: 2026-06-13 America/New_York

```json
{
  "receipt_schema": "source-atlas-r2-release-receipt.v1",
  "receipt_id": "<public-non-private-receipt-id>",
  "owner_issue": "<AMB issue id>",
  "release_ring": "staging",
  "created_at_utc": "<timestamp>",
  "created_by_role": "<role-only-no-secret>",
  "artifact_ids": ["<public-artifact-id>"],
  "artifact_paths": ["<immutable-r2-key>"],
  "artifact_sha256": ["<sha256>"],
  "artifact_etags": ["<etag-if-available>"],
  "source_binding": {
    "source_ids": ["<public-source-id>"],
    "source_authority_state": "<reviewed|source_needed|blocked>",
    "redistribution_posture": "<public-reference-allowed|blocked|needs-review>"
  },
  "validation": {
    "commands": ["<validator command>"],
    "result": "<pass|yellow|fail>",
    "validation_report_paths": ["<artifact path>"]
  },
  "review": {
    "risk_class": "<none|low|high|unknown>",
    "jurisdiction_state": "<global|jurisdiction-needed|blocked>",
    "review_state": "<reviewed|review-needed|blocked>"
  },
  "freshness": {
    "freshness_manifest_id": "<id>",
    "revocation_manifest_id": "<id>",
    "stale_after": "<timestamp-or-null>"
  },
  "compatibility": {
    "compatibility_manifest_id": "<id>",
    "min_runtime_schema": "<schema>",
    "fallback_behavior": "<last_known_good|source_needed|blocked>"
  },
  "rollback": {
    "rollback_manifest_id": "<id>",
    "rollback_target": "<immutable-r2-key-or-null>",
    "rollback_drill_state": "<not-required-for-staging|required-before-production|passed>"
  },
  "privacy_boundary": {
    "contains_private_user_data": false,
    "contains_secret_material": false,
    "no_runtime_write_credentials": true
  },
  "claim_boundary": {
    "runtime_eligible": false,
    "runtime_consumption_claimed": false,
    "production_readiness_claimed": false
  }
}
```

## Required Failure Behavior

Missing source binding, missing freshness/revocation, missing release receipt, missing rollback, missing compatibility, missing risk/jurisdiction review, private-data presence, secret presence, unsupported schema, hash mismatch, ETag mismatch, stale source, revoked source, or unknown signer state fails closed to `review_needed`, `quarantined`, `blocked`, or `source_needed`.

## Non-Claims

This template does not implement receipt storage, signing, app runtime consumption, production promotion, privacy/legal approval, release readiness, or production certification.
