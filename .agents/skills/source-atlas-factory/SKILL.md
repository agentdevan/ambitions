---
name: source-atlas-factory
description: Goal Mode support skill for Ambitions Source Atlas Factory governance, pack/seed gates, public-reference-only R2 boundaries, source authority, release receipts, and runtime eligibility controls.
---

# Source Atlas Factory

Use this skill for Source Atlas Factory governance, pack/seed hardening, source authority, release receipt, and PLOS Source Atlas support work. It is subordinate to `docs/truth/*`, `AGENTS.md`, active Linear `AMB-*` issues, and `artifacts/source-atlas-factory/SAF_GOAL.md`.

## Hard Scope

This skill does not authorize:

- New PLOS runtime feature implementation.
- Duplicate Source Atlas architecture.
- Private user data in R2 or public Source Atlas material.
- Runtime eligibility without pack/seed/source authority gates.
- Required cloud LLM, hosted planning, telemetry, analytics, hosted CI, or paid service dependencies.
- Release, App Review, privacy/legal, device, accessibility, or performance claims without proof.

## Required Read Order

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. `artifacts/source-atlas-factory/SAF_GOAL.md`
10. `artifacts/source-atlas-factory/SAF-run-state.md`
11. `artifacts/source-atlas-factory/SAF_HARDENING_PLAN.md`
12. `artifacts/source-atlas-factory/SAF_PACK_RELEASE_LEDGER.md`
13. `artifacts/source-atlas-factory/SAF_RISK_REGISTER.md`
14. Relevant live Source Atlas tooling and active `AMB-*` issue

For PLOS phases, also read:

- `artifacts/plos-runtime/PLOS_GOAL.md`
- `artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.md`
- `artifacts/plos-runtime/PLOS_PHASE_GATES.md`

## Boundary Law

Source Atlas distribution is public-reference-only. Private user data in R2 is Red.

Allowed:

- Public reference material.
- Public source metadata.
- Pack manifests, hashes, signatures, source authority records, release receipts, revocation records, and rollback notes.

Forbidden:

- User goals, calendar context, files, OCR, photos, private notes, private profile data, health/location data, recommendation state, execution receipts, and any private user-derived context.

## Pack / Seed Gates

Every pack or seed must include:

- Source binding.
- Freshness.
- Revocation.
- Risk/jurisdiction review.
- Release receipt.
- Runtime eligibility state.
- Rollback.

Default runtime eligibility is `not_eligible`. Any higher state requires proof and review.

## Validator Support

Run:

```bash
python3 scripts/codex/source-atlas-readiness-validate.py
python3 scripts/codex/source-atlas-readiness-validate.py --self-test
```

The validator is structural. It does not prove pack correctness, legal rights, privacy approval, release readiness, or runtime behavior.

## Closeout

Closeout must state:

- Actual `AMB-*` issue identifier.
- Whether packs/seeds were published.
- Whether runtime eligibility changed.
- Whether R2 or public objects changed.
- Whether private user data was touched.
- Validation commands and result.
- Yellow/Red limits and next action.

## Red Stops

Stop if:

- Private user data is proposed for R2 or public Source Atlas material.
- A pack/seed lacks source binding, freshness, revocation, release receipt, runtime eligibility state, or rollback.
- Existing Source Atlas tooling is bypassed without proof.
- Runtime uses a pack without eligibility proof.
- A closeout claims privacy/legal/release/runtime readiness without evidence.
