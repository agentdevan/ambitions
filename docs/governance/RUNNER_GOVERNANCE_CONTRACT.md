# Ambitions Runner Governance Contract

Status: ACTIVE

## Purpose

Defines mandatory governance behavior for every autonomous Codex batch.

## Required Runner Behavior

Every autonomous batch execution must:

1. Run repo doctor before execution.
2. Generate canon impact analysis.
3. Generate governance reconciliation outputs.
4. Generate cleanup plans.
5. Generate lineage scoring.
6. Generate dashboard outputs.
7. Regenerate stale overlay scans.
8. Regenerate archive candidate scans.
9. Validate governance outputs.
10. Run repo doctor again after completion.

## Hard Rules

If repo doctor strict mode fails:
- feature expansion stops
- governance remediation becomes highest priority

## Canon Change Rule

If canon changes:
- affected prompts must be detected
- affected frontend surfaces must be detected
- affected encyclopedia bindings must be detected
- retired canon must be classified
- supersession plans must be regenerated

## Generated Governance Outputs

Generated governance artifacts are operational authority.

Manual operational drift outside generated governance outputs is forbidden.
