# Article 34 — CloudKit continuity

## CLOUDKIT-001 — Local authority

CloudKit provides optional continuity. It does not become the only readable copy, block local core, or become canonical command authority.

## CLOUDKIT-002 — Stable record identity

Cloud records preserve canonical object identity, schema version, causal metadata, tombstones, and attachment references without exposing data outside the user’s private container boundary.

## CLOUDKIT-003 — Merge and conflict

Merge behavior is deterministic. Unresolvable conflicts are quarantined and shown as human-meaningful changes. Silent last-write-wins data loss is forbidden.

## CLOUDKIT-004 — Retry and partial failure

Sync defines retry/backoff, batching, quotas, token expiration, partial failure, network changes, iCloud disabled, account changes, old clients, and device removal.

## CLOUDKIT-005 — Environment separation

Development and production schemas/containers are separated and deployed through reviewed procedures. Production schema mutation requires migration and rollback planning.

## CLOUDKIT-006 — Backup/restore interaction

Restore while sync is active defines duplicate prevention, causal reset, upload/download precedence, and user-visible consequence review.

---
