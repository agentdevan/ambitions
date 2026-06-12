# Source Atlas R2 Boundary Standard

R2 is allowed only for public-reference Source Atlas distribution. It is not user-private storage.

## Allowed In R2

- Public reference packs with redistribution authority.
- Public source metadata.
- Signed manifests, hashes, release receipts, revocation manifests, and rollback manifests.
- Non-user-specific seed templates that passed pack/seed gates.

## Forbidden In R2

- User goals, steps, schedules, receipts, profile, local context, private imports, files, photos, OCR output, reminders, health, location, private notes, or inferred private state.
- Any source pack that includes private or user-derived material.
- Any unpublished or unreviewed runtime-eligible pack.

## Required Controls

- Bucket/object naming separates public reference material from all local user data paths.
- Release receipt records object path, hash, signer, validator, and rollback.
- Revocation path exists before runtime consumption.
- App runtime degrades safely if public source material is revoked or stale.

## Verdict Rules

Private user data in R2 is Red. Missing revocation or rollback is Red for runtime eligibility. Missing external/legal proof is Yellow at best, never Green.
