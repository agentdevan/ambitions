# Validation

Status: `PASSED`

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

## Final commit-range checks

- `scripts/ci/ambitions-gitleaks-scan.sh --range-only` with base
  `74370723b84084f2cac4b5aa60bfccbad70e6aea`: passed; two commits scanned and
  no leaks found.
- Changed-path audit over the same base: passed; all 13 paths are limited to
  the R14 owner record, reconciled plan, and this transfer package.
- `git diff --check 74370723b..HEAD`: passed.
- Local `main` and `origin/main`: unchanged and synchronized at
  `74370723b84084f2cac4b5aa60bfccbad70e6aea`.
- Final worktree inspection: clean after the validation record commit.
