# GREEN-REPO-STANDARDS-01 Accessibility Source Check

## Scope

- `Native/Ambitions/App/ShellCommandModels.swift`
- `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- `Native/AmbitionsTests/App/AppIntentRoutingTests.swift`

## Findings

- `ShellCommandModels.swift` and `OpenAmbitionsDestinationIntent.swift` are command/router/source-contract surfaces, not user-tappable object surfaces.
- `AmbitionsUITests.swift` and `AppIntentRoutingTests.swift` are verification assets and were not expanded to change accessibility contracts.
- This patch did not add, remove, or weaken accessibility labels/identifiers.
- No new touched UI action object was introduced in this phase; therefore this phase did not create new accessibility-source obligations.

## Required Source-Access Pass (Narrowed)

- `accessibilityLabel`: no new additions needed in scope; existing coverage remains in runtime feature surfaces.
- `accessibilityValue`: no new additions needed in scope.
- `accessibilityHint`: no new additions needed in scope.
- `accessibilityIdentifier`: no new additions needed in scope.
- `dynamicTypeSize`: no new additions needed in scope.
- `accessibilityReduceMotion`: no new additions needed in scope.

## Claims Not Made

- fully accessible
- VoiceOver verified
- Dynamic Type verified
- Reduce Motion verified

## Notes

- Accessibility proof is tracked in feature surfaces outside this boundary and remains unclaimed without manual verification.
