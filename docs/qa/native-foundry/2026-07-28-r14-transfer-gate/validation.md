# Validation

Status: `PENDING_FINAL_VALIDATION`

This docs-only gate runs canon consistency, available Markdown validation,
introduced-range secret scanning, whitespace validation, a changed-path audit,
and final worktree inspection. Swift, package, Xcode, UI, Simulator,
screenshot, recording, and performance lanes are intentionally out of scope.

Focused canon/compiler tests are not required because no canon/compiler input
or generated authority changes.

## Completed before commit

- `python3 scripts/ambitions-canon.py check`: passed; 66 documents, 466
  requirements, 47 UX screens, 39 visual contracts, 16 local links, and 48 JSON
  files checked.
- `markdownlint-cli2` over all 13 changed or new Markdown files: passed with
  zero errors.
- `git diff --check`: passed.
- Single read-only reviewer: passed after the documented narrow repairs.

The introduced-commit-range Gitleaks scan, final changed-path audit, and final
worktree inspection are recorded after the documentation commits exist.
