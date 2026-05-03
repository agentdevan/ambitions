# DAV Dynamic Adaptive Visual Runbook

<!-- markdownlint-disable MD013 -->

Status: Active DAV operator runbook.
Date: 2026-05-03

## Run Order

Run DAV01 through DAV15 in order. Continue automatically through Green and accepted Yellow. Stop only on unrecoverable Red: persistence/schema requirement, route/raw value change, dependency addition without approval, privacy/security uncertainty, accessibility blocker, release-claim falsehood, destructive overwrite, or repeated same-root Red.

## Implementation Rules

- Name files before production Swift edits.
- Prefer shared design-system primitives in `Sources/Components` when reusable across surfaces.
- Keep surface work inside the existing feature owner folders.
- Preserve existing accessibility identifiers unless a batch explicitly maps and proves changes.
- Use previews/fixtures for normal, empty, overloaded, recovery, Reduce Motion, and high Dynamic Type states where relevant.
- Run `xcodegen generate` after project-shape changes; for source-only additions under existing source roots, run the narrowest useful build/test lane.

## Required Validation

Use the DAV scripts, `git diff --check`, implementation-boundary scans, PXEQ scans, focused xcodebuild build/test lane when Swift changes, docs QA, and batch-train gate check.

