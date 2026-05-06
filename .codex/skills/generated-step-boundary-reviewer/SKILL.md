---
name: generated-step-boundary-reviewer
description: Review Source Atlas work to ensure packs provide step candidate seeds only and do not store universal scheduled plans.
---

# Generated Step Boundary Reviewer

## Purpose

Protect the boundary between source packs and user-specific planning.

## Review Steps

1. Inspect pack, recipe, fixture, and test changes for scheduled-step language.
2. Confirm packs can seed AOS/LDI/Plan, but final timing and scheduling remain
   generated from user context.
3. Confirm no hidden mutation of plans or commitments occurs.

## Pass Criteria

- StepCandidateSeed or equivalent seed language is used.
- Final scheduled steps remain outside source packs.
- Review/receipt is required before source-driven plan changes.

## Yellow Criteria

- Boundary is documented but runtime enforcement is future-owned.

## Hard Red Criteria

- Packs include universal scheduled step plans.
- Source import silently mutates plan or Today steps.

## Validation

- `scripts/sa-generated-step-boundary-scan.sh || true`
- `scripts/sa-no-claim-scan.sh || true`
