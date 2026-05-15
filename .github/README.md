# GitHub Automation Policy

Status: Active repo policy

Ambitions does not use hosted GitHub Actions workflows as automatic validation on every commit.

## Current Policy

- No tracked `.github/workflows/*.yml` file should run on `push` by default.
- Validation proof must come from local scripts, local terminal logs, local Xcode / `xcodebuild`, local simulator/device evidence, checked-in reports, and release-truth review.
- Hosted GitHub Actions logs, artifacts, or generated commits are not current proof sources unless a future human-approved policy explicitly restores a manual-only workflow.

## If A Workflow Is Reintroduced

Any future workflow must be explicit, bounded, and manual by default:

```yaml
on:
  workflow_dispatch:
```

Do not add `push` or `pull_request` triggers without a specific policy change and a matching audit note.

## Proof Boundary

This directory-level policy does not prove local validation passed. It only records that hosted automatic CI is intentionally absent from the active repo path.
