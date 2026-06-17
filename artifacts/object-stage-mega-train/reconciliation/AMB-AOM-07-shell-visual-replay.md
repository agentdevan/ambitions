# AMB-AOM-07 Shell Visual Foundation Replay

Status: `GREEN_REPLAY_SOURCE_DELTA`

This replay closes the AMB-AOM-07 Yellow by adding a shared shell sensory feedback policy and wiring it into shell interactions.

## Source changes

- `Native/Ambitions/App/AppShellSensoryFeedbackPolicy.swift`
- `Native/Ambitions/App/AppMeridianShell.swift`
- `Native/Ambitions/App/AppShellView.swift`
- `Native/AmbitionsTests/App/AppShellSensoryFeedbackPolicyTests.swift`

## Scope result

- Four-surface shell remains unchanged.
- Bottom rail emits shared surface-selection feedback.
- Header actions emit shared shell-action feedback.
- Reduce Motion disables shell feedback emission.
- Feedback intents expose accessible descriptions for equivalent non-haptic semantics.

## Next gate

Proceed to AMB-AOM-08 Today blocker validation.
