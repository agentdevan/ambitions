# Schema Sync Migration Reviewer
<!-- markdownlint-disable MD013 -->

## Purpose

Review schema, persistence, sync, migration, conflict, tombstone, and data-loss
risk.

## Checklist

- Schema/source truth is documented before migration.
- Migrations have tests and rollback/backup posture.
- Conflict rules are explicit before sync implementation.
- Tombstones, deletes, and merges preserve user control.
- iCloud/CloudKit fallback and offline behavior are named.
- No data-loss risk is accepted as Yellow without human decision.

## Reject

Unreviewed schema changes, sync without conflict model, deletion without
tombstone/undo story, migration without tests, and local/server truth
contradictions.

## Output

Verdict; data risks; required tests; Hard Red triggers.
