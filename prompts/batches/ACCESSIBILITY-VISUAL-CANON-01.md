<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# ACCESSIBILITY-VISUAL-CANON-01 — Accessibility Equivalent Coverage

## Batch ID

ACCESSIBILITY-VISUAL-CANON-01

## Objective

Prepare accessibility-equivalent requirements for the visual canon lane and define
hard blockers when proof does not exist.

## Scope

- VoiceOver grouping expectations.
- Dynamic Type and Reduce Motion behavior expectations.
- Non-color-only state encoding and contrast-safe variants.
- `44pt` minimum touch target constraint.

## Constraints

- Do not claim public accessibility conformance in this phase.
- Keep accessibility promises evidence-bound for implementation batches.
- No generic "screen-reader perfect" or "compliant" statements without logs.

## EFC / claim boundaries

- EFC applicability: invoked.
- Marked as `blocked-until-clean` when logs or equivalent proof artifacts are missing.
