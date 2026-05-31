# AFRI-028 Deep App Intents Action Surface Proof

Issue: AMB-380 / AFRI-028

## Scope

- Expanded the App Intents action surface beyond route opening while preserving canonical `Today / Goals / Capture / Time / You` IA.
- Added parameterized App Intents for Capture, goal draft review, opening a step, starting the current step, guarded step closure, receipt inspection, and bounded local knowledge inspection.
- Kept the public App Shortcuts provider within the iOS 10-shortcut metadata cap by advertising goal draft as the one added shortcut while leaving the other parameterized intents available to Shortcuts.
- Kept mutation-capable step closure as app-open confirmation with receipt posture instead of silent external mutation.
- Kept local knowledge inspection routed through `What Ambitions Knows` and the app intent origin boundary.

## Safety Boundaries

- Capture and goal draft intents queue local review requests through the shared local creation queue; they do not send content to a network service or external processor.
- Current-step open and start actions only route into Ambitions.
- Guarded close step routes into Ambitions for confirmation and receipt creation; it does not complete a step from Shortcuts alone.
- Receipt and local knowledge inspection route into the local memory lens surface and keep sensitive details private until Ambitions opens.
- SourceRecord, Receipt, ReplayTrace, and You / What Ambitions Knows claims remain bounded to source and focused-test evidence here; this is not device Shortcuts/Siri proof.

## Validation

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-380 --prompt /tmp/AMB-380-AFRI-028-guard-prompt.md`
- Initial focused App Intent run was Red on the iOS App Shortcuts metadata cap: 15 shortcuts exceeded the platform maximum of 10. Repair kept the new parameterized intents but advertised only the added goal draft shortcut.
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/AppIntentRoutingTests` passed after repair: 12 tests, 0 failures.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-380 --prompt /tmp/AMB-380-AFRI-028-guard-prompt.md --changed-from HEAD --changed-path Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift --changed-path Native/AmbitionsTests/App/AppIntentRoutingTests.swift --changed-path docs/proof/afri/afri-028-deep-app-intents-action-surface-proof.md`
- `git diff --check`
- `rg -n "OpenAI|ChatGPT|LLM|analytics|telemetry|http://|https://|URLSession|Firebase|Amplitude|Segment|Mixpanel" Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift docs/proof/afri/afri-028-deep-app-intents-action-surface-proof.md` returned no matches.

## Proof Boundary

This proof records source and focused-test coverage only. It does not claim real Shortcuts app invocation, Siri invocation, Spotlight behavior, physical-device behavior, App Store readiness, TestFlight readiness, public accessibility proof, privacy/legal approval, or release readiness.

## Rollback

Disable the new AppShortcut entries and leave the underlying App Intent types unadvertised until safety review passes.
