---
name: ambitions-no-cost-gate
description: Prevent hidden cost, API/network, CI, and package-install exposure in local Codex OS changes.
---

## Inputs
- Command plan, changed files, validator output.

## Checks
- No API-key env var introduction.
- No package install command additions.
- No CI workflow/provider additions.
- No external network downloads in scope.
- No new paid service dependency.

## Rollback
- Revert the modified path files and re-run validator.
