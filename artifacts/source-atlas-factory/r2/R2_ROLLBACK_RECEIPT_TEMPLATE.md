# R2 Rollback Receipt Template

Status: Green for AMB-973 staging template scope; rollback drill proof remains future-owned.
Date: 2026-06-13 America/New_York

```json
{
  "receipt_schema": "source-atlas-r2-rollback-receipt.v1",
  "receipt_id": "<public-non-private-rollback-receipt-id>",
  "owner_issue": "<AMB issue id>",
  "release_ring": "staging",
  "created_at_utc": "<timestamp>",
  "rollback_reason_class": "<source_changed|freshness_expired|security_revoked|signer_revoked|hash_mismatch|schema_replaced|policy_updated|private_data_leak|jurisdiction_changed|data_error|operator_error>",
  "severity": "<block|quarantine|degraded>",
  "bad_artifact": {
    "artifact_id": "<public-artifact-id>",
    "version": "<version>",
    "sha256": "<sha256>",
    "immutable_path": "<r2-key>",
    "etag": "<etag-if-available>"
  },
  "target_artifact": {
    "artifact_id": "<public-artifact-id-or-null>",
    "version": "<version-or-null>",
    "sha256": "<sha256-or-null>",
    "immutable_path": "<r2-key-or-null>",
    "etag": "<etag-if-available-or-null>"
  },
  "control_manifests": {
    "current_manifest_id_before": "<id>",
    "current_manifest_id_after": "<id-or-null>",
    "revocation_manifest_id": "<id>",
    "rollback_manifest_id": "<id>",
    "compatibility_manifest_id": "<id>",
    "freshness_manifest_id": "<id>"
  },
  "validation": {
    "commands": ["<validator command>"],
    "result": "<pass|yellow|fail>",
    "evidence_paths": ["<artifact path>"]
  },
  "privacy_boundary": {
    "contains_private_user_data": false,
    "contains_secret_material": false,
    "no_runtime_write_credentials": true
  },
  "claim_boundary": {
    "runtime_consumption_claimed": false,
    "production_readiness_claimed": false
  }
}
```

## Required Failure Behavior

A rollback target is usable only when it verifies by exact path, hash/checksum or signature state, compatibility, freshness, revocation, source authority, release receipt, and privacy boundary. If any check fails, route to `blocked`, `quarantined`, `source_needed`, or `review_needed`.

## Non-Claims

This template does not perform rollback, prove rollback drill success, implement runtime rollback evaluation, mark any pack runtime-eligible, or certify production readiness.
