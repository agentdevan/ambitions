# Eval Prompt 04: capture-flow-implementer

## Prompt

Expand `CaptureSourceType` so Ambitions can distinguish notification-originated captures and wire the change end-to-end through the capture inbox, but do not invent a new runtime notification ingestion seam if the repo does not already have one.

## Expected Likely Skill(s)

- `phase-executor` if the change touches multiple layers
- `capture-flow-implementer`
- `ios-qa-regression-checker`

## Success Looks Like

- Updates model, persistence/service usage, screen metadata, and tests coherently.
- Preserves the existing Ambitions capture terminology and flow.
- Checks routing/container implications if notification entry is involved.
- Explicitly distinguishes domain/service support from runtime notification ingestion support.

## Common Failure Patterns

- Only edits the enum and stops.
- Rebrands captures as a generic task inbox.
- Misses tests or screen metadata updates.
- Invents a brand-new notification runtime seam without grounding in existing code.

## Files That Should Probably Be Touched

- `Native/Ambitions/Domain/CaptureModels.swift`
- `Native/Ambitions/Services/CaptureService.swift`
- capture repository/tests
- `Native/Ambitions/Features/Captures/CapturesScreen.swift`

## Files That Should Not Be Touched By Default

- planner-only files
- unrelated docs
