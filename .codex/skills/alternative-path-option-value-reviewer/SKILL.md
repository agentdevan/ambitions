---
name: alternative-path-option-value-reviewer
description: Review Source Atlas alternative path, option value, transferable proof, and Still Counts behavior.
---

# Alternative Path Option Value Reviewer

## Purpose

Ensure serious paths preserve alternatives and transferable proof without
claiming unsupported outcomes.

## Review Steps

1. Inspect AlternativePathSet, OptionValueMap, proof transfer, and receipt
   changes.
2. Confirm adjacent paths are present or explicitly absent with reason.
3. Confirm proof transfer depends on source/requirement/evidence overlap.

## Pass Criteria

- Alternative path and option-value states are explicit.
- Still Counts language is non-shaming and source-bound where relevant.
- No career, education, legal, or eligibility certainty is introduced.

## Yellow Criteria

- Alternative path contract exists but runtime transfer is future-owned.

## Hard Red Criteria

- Serious paths omit alternatives without explanation.
- Proof transfers across requirements without source/evidence support.

## Validation

- `scripts/sa-alternative-path-option-value-scan.sh || true`
- `scripts/sa-projection-fixture-coverage-scan.sh || true`
