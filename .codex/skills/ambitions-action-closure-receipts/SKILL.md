---
name: ambitions-action-closure-receipts
description: Use for Step Occurrence, Action Closure, closure outcomes, closure receipts, Still Counts, Needs a quick check, Today closure prompts, Trust Center receipt history, and Goal Detail receipt trails. Enforces non-punitive unresolved-step language, visible receipts, retroactive closure, and additive compatibility with existing receipt/search/privacy contracts.
---

# Ambitions Action Closure Receipts

## Purpose

Use this skill for Step Occurrence, Action Closure, closure states, closure receipts, Still Counts, Needs a quick check, Today closure prompts, Trust Center receipt history, and Goal Detail receipt surfaces.

## Required Grounding

Locate existing receipt and closure seams before creating models:

- `rg -n "ActionClosureReceipt|Receipt|Closure|Still Counts|Needs a quick check|Moved|Rescheduled|Skipped|Blocked|Waiting|Needs Review" Native Sources AppUI`
- Inspect existing receipt search, privacy, safe-to-show, redaction, undo, proof, trust label, Today, Trust Center, and Goal Detail projections.

Preserve existing receipt/search/privacy contracts.

## Product Rules

- Ambitions does not auto-complete a step when time passes.
- Ambitions does not mark a step failed because the user forgot to open the app.
- A scheduled occurrence eventually needs a closure outcome.
- Prior unresolved steps become `Needs a quick check`, not punitive state language.
- Retroactive closure is supported.
- Closure receipts record what changed, when, why, source, and undo/review status.
- Closure receipts appear in Today, Trust Center, and Goal Detail.
- Today does not become a graveyard of old steps.

## Supported Closure Outcomes

- `Completed`
- `Still Counts`
- `Moved / Rescheduled`
- `Skipped Intentionally`
- `Not Needed`
- `Blocked`
- `Waiting`
- `Needs Recovery`
- `Needs Review`

## Forbidden Normal User-Facing States

Do not introduce these as normal unresolved-step states:

- `Failed`
- `Missed`
- `Overdue`
- `Behind`
- `Neglected`
- `Incomplete`

## Procedure

1. Locate existing `ActionClosureReceipt` models before creating new models.
2. Preserve existing receipt/search/privacy/redaction contracts.
3. Add only additive models/adapters where possible.
4. Update Today closure prompt behavior.
5. Update Trust Center receipt visibility.
6. Update Goal Detail receipt trails.
7. Add fixtures for yesterday loose ends, Still Counts, retroactive completion, rescheduled step, waiting dependency, and recovery.
8. Add tests for user-facing state language and receipt projection where useful.
9. Keep changes local-first and deterministic; do not add sync/network/account dependencies.

## Validation

- Run focused receipt, Today, Trust Center/You, and Goal Detail tests touched by the change.
- Scan touched visible copy for forbidden state language.
- Run `xcodegen generate` when target membership changes.
- Run `git diff --check`.
- Do not claim receipt visibility on a surface unless code/tests or inspected UI prove it.

## Follow-On Skills

- Use `ambitions-time-context-builder` if closure depends on schedule, occurrence, duration, or reflow semantics.
- Use `ambitions-ios-surface-polisher` for visible closure panels, receipt trails, and check-in surfaces.
- Use `ambitions-v2-validation-closeout` before claiming broad v2 receipt alignment complete.
