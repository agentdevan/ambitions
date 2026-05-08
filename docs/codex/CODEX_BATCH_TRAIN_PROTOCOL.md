# Codex Batch Train Protocol

Status: Active Codex OS batch-train protocol.
Date: 2026-05-07

## Continuation

- Continue through Green.
- Continue through accepted Yellow only when owner, safety reason, and no-claim boundary are recorded.
- Do not stop on accepted Yellow when those fields are present and the next batch is safe.
- Stop on hard Red.

## Mandatory Stops

- Unknown dirty tree.
- Destructive conflict or overwrite need.
- Privacy/security/legal ambiguity.
- Unsupported release/device/accessibility/legal/privacy claim.
- Repeated same-root Red after two repair attempts.
- Unowned dependency gap.
- Missing route/source owner for the next batch.

## No Double Work

Before starting a batch, search owner docs, prompts, audit reports, source files, skills, scripts, and maps for existing equivalents. Extend or reconcile owners instead of creating duplicates.

## Commit Cadence

Use one logical commit per batch or Codex OS upgrade. Do not mix product implementation and Codex OS governance in one commit unless the user explicitly scopes it that way.

## Restartability

Every interruption point must produce or preserve enough state to restart:

- selected route
- active batch
- allowed/forbidden files
- files touched
- commands and exit codes
- raw log paths
- Green/Yellow/Red classification
- next eligible action
