# Eval Prompt 04: capture-flow-implementer

## Prompt

Expand `CaptureSourceType` so Ambitions can distinguish notification-originated captures and wire the change end-to-end through the capture inbox.

## Success Looks Like

- Updates model, persistence/service usage, screen metadata, and tests coherently.
- Preserves the existing Ambitions capture terminology and flow.
- Checks routing/container implications if notification entry is involved.

## Common Failure Patterns

- Only edits the enum and stops.
- Rebrands captures as a generic task inbox.
- Misses tests or screen metadata updates.

## Files That Should Probably Be Touched

- `Native/Ambitions/Domain/CaptureModels.swift`
- `Native/Ambitions/Services/CaptureService.swift`
- capture repository/tests
- `Native/Ambitions/Features/Captures/CapturesScreen.swift`

## Should Not Touch By Default

- planner-only files
- unrelated docs
