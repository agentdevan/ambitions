# Source Atlas Seed Standard

Seeds are reusable source-backed starting material for packs or runtime reasoning. They are not user data and not runtime proof.

## Required Seed Contract

- Seed id and version.
- Source binding and provenance.
- Allowed domains and excluded domains.
- Freshness and stale handling.
- Risk/jurisdiction classification.
- Review owner and review timestamp.
- Runtime eligibility state.
- Rollback and revocation behavior.

## Seed Limits

- Seeds may not contain private user data.
- Seeds may not silently become runtime-eligible.
- Seeds may not override live source authority or user-owned constraints.
- Seeds may not imply legal, medical, financial, or other high-risk advice without high-risk gates.

## Validation

- Structural validator passes.
- Source Atlas reviewer passes.
- PLOS phase gate passes if the seed is used by a PLOS runtime phase.
