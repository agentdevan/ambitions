---
name: release-hardening
description: Run a final Ambitions preflight across docs truth, plist/privacy/entitlements, extension setup, build reproducibility, and release sanity before merge or release. Use when preparing a branch for merge, doing final preflight, or hardening changes that touch targets, OS capabilities, or shipped documentation; chain to `repo-truth-enforcer` and `ios-qa-regression-checker` where appropriate; do not use for early feature planning or small isolated edits that are not near integration.
---

# Release Hardening

## Purpose

Perform the final repo-level merge or release check so the branch is truthful, buildable, and not carrying silent config or docs drift.

## When To Use

- `prepare for merge`
- `release harden this branch`
- `final preflight`
- before landing target, plist, entitlement, extension, or release-facing docs changes

## When Not To Use

- The task is still in active design or early implementation.
- The user only wants a feature plan.
- The branch has not reached a state where build/test validation is meaningful.

## Required Inputs

- The current diff.
- Relevant build/test docs and CI workflow.
- Any plist, entitlement, privacy, or extension files touched by the branch.

## Execution Steps

0. If the branch spans multiple release-sensitive areas, start with `release-plan.md` or a brief `phase-executor` plan.
1. Audit the diff for release-sensitive files:
   - `project.yml`
   - plist files
   - entitlements
   - privacy manifest
   - extension targets
   - docs and manual test notes
2. Re-check repo truth. Docs and copy should match the actual shipped branch state.
3. Work in bounded preflight slices instead of a single pass: docs truth, config/privacy, validation, then final report.
4. After each slice, self-check whether the branch is actually closer to releasable or whether a block remains.
5. Verify build reproducibility through the repo’s documented XcodeGen and `xcodebuild` flow where possible.
6. If extension or OS-surface changes landed, confirm manual validation notes exist and point at the correct behavior.
7. Report remaining release risk instead of hand-waving it away.

## Skill Chaining

- Use `repo-truth-enforcer` when docs or product claims need reconciliation.
- Use `ios-qa-regression-checker` for the validation summary.

## Failure Recovery

- If validation is environment-limited, do not block on impossible checks; separate verified, unverified, and manual follow-up explicitly.
- If the branch is not mature enough for release hardening, say so and stop short of a false readiness claim.
- If the remaining readiness claim depends on unavailable signing, simulator, or archive checks, stop with a blocked-work summary rather than implying release readiness.

Use the checklist in `templates/release-hardening-checklist.md`.

## Output Format Expectations

Summaries should include:

1. release-sensitive areas checked
2. validation run
3. docs/config/manual-note status
4. remaining blockers or clean preflight

## Validation Requirements

- Do not mark the branch release-ready unless the available validation actually supports that claim.
- Verify config truth for plist, entitlements, app groups, privacy manifest, and target wiring.
- Verify docs reflect the branch’s real shipped state, not past or planned states.

## Ambitions-Specific Guardrails

- Use the native SwiftUI app and `project.yml` as the release source of truth.
- Check current `Info.plist`, entitlements, `PrivacyInfo.xcprivacy`, and extension folders directly instead of trusting older docs.
- Keep manual-test notes current for widgets, Live Activities, share flows, or other OS surfaces.
- Prefer a short honest blocker list over a false `ready` claim.

## Trigger Phrases

- `prepare for merge`
- `release harden this branch`
- `final preflight`
- `do the final native release sanity pass`
