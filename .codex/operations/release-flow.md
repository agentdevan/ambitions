# Release Flow

## Pre-Merge Sequence

1. confirm docs truth for the shipped branch state
2. confirm `project.yml`, plist, entitlements, privacy manifest, and extension setup changes
3. run or document the strongest available validation path
4. record manual follow-up still required
5. produce merge-readiness output without overstating readiness

## Use These Layers

- `release-hardening` for the final pass
- `repo-truth-enforcer` for docs truth gaps
- `ios-qa-regression-checker` for validation reporting
- `.codex/templates/release-checklist.md` and `.codex/templates/merge-readiness.md` for output structure
