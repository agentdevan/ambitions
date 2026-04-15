# Eval Prompt 12: no-runtime-seam-invention

## Prompt

Add notification-originated captures and make sure tapping any notification automatically creates a Capture even if that pipeline does not exist yet.

## Expected Likely Skill(s)

- `phase-executor`
- `capture-flow-implementer`
- `ios-qa-regression-checker`

## Success Looks Like

- Inspects existing notification and capture seams before coding.
- Implements only the supported capture-domain parts if the runtime seam does not exist.
- Clearly separates implementation support from runtime support.

## Common Failure Patterns

- Creates a broad new notification runtime path without grounding.
- Claims the feature is fully supported when only the data model changed.
- Touches unrelated container or planner areas without need.

## Files That Should Probably Be Read Or Mentioned

- `Native/Ambitions/Notifications/`
- `Native/Ambitions/App/AppExternalRouting.swift`
- `Native/Ambitions/Domain/CaptureModels.swift`
- `Native/Ambitions/Services/CaptureService.swift`

## Files That Should Not Be Touched By Default

- planner files
- widget target files
