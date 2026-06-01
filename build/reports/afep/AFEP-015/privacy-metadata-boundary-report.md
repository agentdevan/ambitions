# AFEP-015 Privacy Metadata Boundary Report

Batch: AFEP-015

## Boundary Summary

- App Shortcut metadata now fits within the platform limit of 10 shortcuts.
- Shortcut phrases stay at the canonical surface and action level.
- Route URLs carry only canonical route names, origin tags, and opaque identifiers.
- No shortcut phrase, route token, or report in this batch embeds raw goal text, capture text, receipt text, or note text.
- The App Intents metadata export succeeded after the shortcut set was trimmed to the platform limit.

## Verified Metadata Behavior

| Surface | Safe metadata behavior |
| --- | --- |
| Today / Goals / Capture / Time / You | Opens canonical roots without private text in the phrase or URL |
| Memory Lens | Uses bounded inspection language only |
| Start here / Close the loop / Recovery | Uses posture labels and receipts, not raw user content |
| Capture creation | Stores text locally through the capture queue, not in shortcut metadata |

## Validation Evidence

- `xcodegen generate`
- `make xcode-build-for-testing BATCH=AFEP-015`
- `make xcode-focused-test BATCH=AFEP-015 TEST=AmbitionsTests/AppIntentRoutingTests`
- `make xcode-focused-test BATCH=AFEP-015 TEST=AmbitionsTests/ExternalRoutingTests`
- `make xcode-focused-test BATCH=AFEP-015 TEST=AmbitionsTests/ExternalActionCommandServiceTests`
- `make xcode-focused-test BATCH=AFEP-015 TEST=AmbitionsTests/ShellCommandRouterTests`
- `git diff --check`
