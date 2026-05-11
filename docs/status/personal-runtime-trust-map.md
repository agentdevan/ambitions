# Personal Runtime & Trust Map — MOAT-ALIGNMENT-01

This map records what can be inspected, retained, changed, and blocked for local trust.

## Local-First Data Boundaries

- Private context model:
  - Ambitions, Goals, Life Area links
  - constraints, commitments, recovery context
  - recommendation trace inputs/decisions
  - closure and proof records
- Primary execution behavior is designed to remain local-first and on-device unless explicitly moved to Apple-native flows.

## What Ambitions May Learn Locally

- Step fit signals and context constraints
- User preference overrides and planning defaults
- Closure choices and recovery behavior
- Capture route outcomes (`proof`, `constraint`, `goal`, etc.)

## What User Can Inspect / Reset / Delete

- Inspected surfaces should expose:
  - what Ambitions has learned
  - what it used for recommendation routing
  - what proof changed state
  - what is currently retained as constraints
- User controls should include:
  - reset learning
  - delete proof history entries where safe
  - export/import path planning
  - correction and recency controls

## Apple Sync Exception (Future)

- Apple-native sync is the only potential future sync path, and only for user-owned, user-enabled data.
- Sync must stay user-controllable, transparent, and reversible.

## R2/Reference-Pack Exception (Future)

- A public/non-personal freshness/reference exception is acceptable for static external packs only.
- R2 must not hold private ambition graph state.

## What Must Never Be Sent Externally

- private captures or proofs,
- raw local capture text that the user has not approved for export,
- life context,
- constraint history,
- private recovery and learning paths,
- raw recommendation source/trace data.

## Privacy-Trust Proof Still Required

- No release/privacy claim is made by this patch.
- Privacy and trust behavior remains model-level and governance-aligned, not yet release-complete.
