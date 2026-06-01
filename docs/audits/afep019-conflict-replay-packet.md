# AFEP-019C Conflict Replay Packet

Batch: AFEP-019C
Purpose: Record the review-first conflict scaffolding added by the bounded patch

## Packet Shape

- `CloudKitContinuityPortableRecordEnvelope`
- `CloudKitContinuityRecordFamily`
- `CloudKitContinuityRecordReviewState`
- `CloudKitContinuityLedgerEntry`
- `CloudKitContinuityOutboxEntry`
- `CloudKitContinuityConflictReview`
- `CloudKitContinuityTombstoneMetadata`
- `CloudKitContinuitySyncLedgerSnapshot`

## Replay Rules

- Local writes are never blocked by sync availability.
- Conflicts stay review-first.
- Tombstone metadata carries the minimum information needed to prevent resurrection.
- The outbox records local intent before any remote attempt.
- The coordinator does not invoke remote writes unless the sync state is proof-backed and the client is explicitly eligible.

## Example State

```text
family: tombstone
recordName: entity_revision_tombstone.goal.goal.1:rev-3
reviewState: needs_review
syncState: needs_review
operation: review
detail: local-first conflict review queued for later inspection
```

## What This Packet Does Not Claim

- It does not claim a live CloudKit merge engine.
- It does not claim remote replay proof.
- It does not claim destructive overwrite behavior.
- It does not claim production sync readiness.

## Local Verification

- Portable envelope round-trip tests passed.
- Local-first coordinator queueing test passed.
- Build-for-testing passed.
