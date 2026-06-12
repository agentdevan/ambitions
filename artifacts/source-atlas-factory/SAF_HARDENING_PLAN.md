# Source Atlas Factory Hardening Plan

Status: Active support plan for PLOS readiness
Updated: 2026-06-12
Scope: Source Atlas Factory governance, validator, and release-boundary hardening only

## Mission

Harden Source Atlas Factory so PLOS phases can use source packs, seeds, public references, and release receipts without privacy/source/safety drift.

This plan does not publish packs, mark packs runtime-eligible, or implement new runtime features.

## Non-Goals

- Do not create a duplicate Source Atlas architecture.
- Do not publish or mark runtime eligibility for any pack without gates.
- Do not put private user data in R2, public objects, seeds, test fixtures, or source packs.
- Do not introduce required cloud LLM, tracking, analytics, telemetry, hosted CI, or paid service dependencies.
- Do not claim privacy, legal, App Review, release, performance, or accessibility readiness.

## Boundary Law

R2 and Source Atlas distribution are public-reference-only. Private user data in R2 is Red.

Allowed Source Atlas material:

- Public reference documents or references with redistribution rights.
- Public source metadata that is non-private and non-user-specific.
- Pack manifests with source binding, hash/signature, freshness, revocation, review, release receipt, rollback, and runtime eligibility state.

Blocked Source Atlas material:

- User goals, tasks, calendar context, health/location context, private imports, or local profile data.
- Private documents, OCR output, photos, files, notes, or reminders.
- Any inferred private profile, private recommendation state, or execution receipt.

## Required Gates

Every pack or seed must declare:

- Source binding: exact source identifiers, provenance, license/redistribution posture, and source authority.
- Freshness: source timestamp, review timestamp, stale threshold, and stale behavior.
- Revocation: kill switch, deprecation path, and downstream invalidation behavior.
- Risk and jurisdiction: high-risk domain status, jurisdiction limits, and reviewer owner.
- Release receipt: who released it, what validator ran, hash/signature, affected packs, and rollback note.
- Runtime eligibility: `not_eligible`, `eligible_after_review`, or `eligible`, with proof for any non-default state.
- Rollback: deterministic rollback path and user-facing degradation behavior if already installed.

## PLOS Phase Integration

- M04 owns public-reference-only R2 distribution mesh.
- M05 owns Source Atlas Pack / Seed Foundry gates.
- M06 owns Source Authority Mesh.
- M09 Step Quality Firewall must be able to reject weak-source steps.
- M10 Golden Slice cannot use a Source Atlas pack unless source binding and runtime eligibility are proven.

## Validator Support

Use:

```bash
python3 scripts/codex/source-atlas-readiness-validate.py
python3 scripts/codex/source-atlas-readiness-validate.py --self-test
```

The validator checks that the hardening plan and core SAF artifacts exist and carry the required control phrases. It is structural proof only; future source-changing phases still need live source inspection and focused validation.

## Reviewer Hooks

Use the PLOS Source Atlas Boundary Reviewer prompt in:

- `.agents/skills/plos-runtime-master-build/references/plos-reviewer-prompts.md`

Use Source Atlas references for pack gates and R2 boundaries:

- `.agents/skills/source-atlas-factory/references/source-atlas-pack-gates.md`
- `.agents/skills/source-atlas-factory/references/source-atlas-r2-boundary-standard.md`

## Current Status

Green for readiness-control declaration after validator pass.

Yellow for future execution:

- Actual live Source Atlas runtime map remains owned by PLOS M01.
- Actual pack/seed release gates remain owned by PLOS M04/M05/M06.
- Actual runtime eligibility proof remains blocked until the relevant phase issue is active.
