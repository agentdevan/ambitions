<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

ACCESSIBILITY-DYNAMIC-TYPE-REDUCE-MOTION-PROOF-01

## Objective

Install focused proof coverage for Dynamic Type, Reduce Motion, VoiceOver/accessibility labels, contrast-safe state meaning, and visible non-gesture alternatives on current key surfaces.

This batch may add tests/previews and small accessibility fixes. It must not claim full public accessibility conformance.

## Active Source Truth To Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `Sources/Accessibility/`
- `Sources/Previews/`
- `Native/Ambitions/Features/Today/`
- `Native/Ambitions/Features/Capture/`
- `Native/Ambitions/Features/Time/`
- `Native/Ambitions/Features/Goals/`
- `Native/Ambitions/Features/You/`
- `Native/AmbitionsTests/App/Accessibility*`
- `Native/AmbitionsTests/DesignSystem/`
- `scripts/dav-dynamic-type-evidence-check.sh`
- `scripts/dav-reduce-motion-check.sh`
- `scripts/dav-voiceover-evidence-check.sh`

## Allowed Scope

- `Sources/Accessibility/**`
- `Sources/Previews/**`
- `Sources/Components/**`
- `Native/Ambitions/Features/**`
- `Native/AmbitionsTests/**`
- relevant accessibility validation scripts

## Required Work

- Add or repair focused tests/proof fixtures for Dynamic Type and Reduce Motion on at least Today, Capture, Time, Goals, and You primary objects where feasible.
- Repair small missing accessibility labels or reduce-motion fallbacks if tests expose them.
- Report any coverage not run as not verified.

## Validation Expectations

- Focused accessibility/design-system tests.
- Relevant local accessibility scripts when non-mutating.
- `git diff --check`

## Forbidden Scope

- No claim of full accessibility conformance.
- No visual redesign unrelated to accessibility proof.
- No release/readiness claims.

## Runner Command

```bash
make batch BATCH=ACCESSIBILITY-DYNAMIC-TYPE-REDUCE-MOTION-PROOF-01 PROMPT=prompts/batches/ACCESSIBILITY-DYNAMIC-TYPE-REDUCE-MOTION-PROOF-01.md
```
