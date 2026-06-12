# Source Atlas Pack Gates

Every Source Atlas pack must satisfy these gates before publication or runtime eligibility.

## Required Fields

- Pack id and version.
- Source binding: source ids, URLs or local references, provenance, license/redistribution posture, authority tier.
- Freshness: source timestamp, review timestamp, stale threshold, stale behavior.
- Risk: domain, high-risk classification, jurisdiction limits, reviewer owner.
- Integrity: hash, signature or signed manifest path, generator version.
- Revocation: kill switch, deprecation path, downstream invalidation.
- Release receipt: releaser, validators, changed packs, rollback note.
- Runtime eligibility: `not_eligible`, `eligible_after_review`, or `eligible`.

## Green

- Source binding, freshness, revocation, release receipt, runtime eligibility, and rollback are complete.
- Pack contains no private user data.
- Validator and reviewer evidence is current.

## Yellow

- Pack is structurally valid but not runtime-eligible.
- External review, rights review, jurisdiction review, or live runtime proof remains incomplete and owned.

## Red

- Private user data in pack or R2.
- Missing source binding, revocation, release receipt, or rollback.
- Runtime eligibility without proof.
- Unclear license/redistribution posture for public distribution.
